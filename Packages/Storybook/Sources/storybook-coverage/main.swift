// cspell:ignore xcworkspace xcodeproj xcresult
import Foundation
import StorybookHistoryKit

// Writes the coverage map, which names the source files each requirement acceptance's test covers.
// Packages' tests run through `swift test`, Xcode schemes' through `xcodebuild`, and Go's through `go test`.
let usage = """
    usage: storybook-coverage [--root <folder>] [--xcode <project, workspace or package folder>]
                              [--scheme <name>] [--destination <specifier>] [--results <folder>]
                              [--exclude <path>]... [output]
    Writes <repo root>/docs/requirements/coverage.json unless output names another file.
    Leaves out the Storybook catalog's own files, and each repo folder or file --exclude names.
    --results reads each Xcode test's <test>.xcresult from an earlier run instead of running it.

    """

struct Options {
    var root = URL(filePath: FileManager.default.currentDirectoryPath)
    var output: URL?
    var xcode: URL?
    var scheme: String?
    var destination = "platform=macOS"
    var results: URL?
    var excluded: [String] = []

    init(_ arguments: [String]) {
        var words = arguments.makeIterator()
        while let word = words.next() {
            let value = { () -> String in
                guard let value = words.next() else { Options.fail("\(word) needs a value") }
                return value
            }
            switch word {
            case "-h", "--help": Options.fail("")
            case _ where Options.valued.contains(word): set(word, value())
            default:
                guard !word.hasPrefix("-"), output == nil else { Options.fail("unknown argument \(word)") }
                output = URL(filePath: word)
            }
        }
    }

    /// The options that take a value, which `set` stores.
    static let valued = ["--root", "--xcode", "--scheme", "--destination", "--results", "--exclude"]

    private mutating func set(_ option: String, _ value: String) {
        switch option {
        case "--root": root = URL(filePath: value)
        case "--xcode": xcode = URL(filePath: value)
        case "--scheme": scheme = value
        case "--destination": destination = value
        case "--results": results = URL(filePath: value)
        case "--exclude": excluded.append(value)
        default: Options.fail("unknown argument \(option)")
        }
    }

    static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data((message.isEmpty ? "" : "\(message)\n").utf8) + Data(usage.utf8))
        exit(2)
    }
}

/// The nearest folder at or above `file`'s, inside `root`, that holds a `Package.swift`.
func package(of file: String, root: URL) -> URL? {
    var folder = root.appending(path: file).deletingLastPathComponent()
    while folder.path(percentEncoded: false).count >= root.path(percentEncoded: false).count {
        if FileManager.default.fileExists(atPath: folder.appending(path: "Package.swift").path) { return folder }
        folder.deleteLastPathComponent()
    }
    return nil
}

/// The repo root's only workspace, else its only project, for tests outside any package.
func xcodeContainer(in root: URL) -> URL? {
    let names = (try? FileManager.default.contentsOfDirectory(atPath: root.path)) ?? []
    for kind in ["xcworkspace", "xcodeproj"] {
        let found = names.filter { $0.hasSuffix(".\(kind)") }.sorted()
        if found.count == 1 { return root.appending(path: found[0]) }
    }
    return nil
}

let options = Options(Array(CommandLine.arguments.dropFirst()))
guard
    let top = try? run(["git", "rev-parse", "--show-toplevel"], in: options.root)
        .trimmingCharacters(in: .whitespacesAndNewlines)
else { Options.fail("\(options.root.path) is not in a git repo") }
let root = URL(filePath: top).resolvingSymlinksInPath()
let output = options.output ?? root.appending(path: StorybookHistoryReader.coverage)

let declarations = StorybookRequirementTests.declarations(in: root)
var covered: [String: [String]] = [:]
do {
    var swiftTests = declarations.filter { $0.path.hasSuffix(".swift") }
    let outside = swiftTests.filter { package(of: $0.path, root: root) == nil }
    let xcode = options.xcode ?? (outside.isEmpty ? nil : xcodeContainer(in: root))
    if options.results != nil, xcode == nil {
        Options.fail("--results reads Xcode result bundles, so it needs --xcode")
    }
    if let xcode {
        let ran = try XcodeCoverage(
            container: xcode.resolvingSymlinksInPath(), scheme: options.scheme, destination: options.destination,
            root: root, results: options.results
        ).covered(swiftTests.map(\.test))
        covered.merge(ran) { $1 }
        swiftTests.removeAll { ran[$0.test] != nil }
    }
    let byPackage = Dictionary(grouping: swiftTests) { package(of: $0.path, root: root) }
    for (folder, tests) in byPackage.sorted(by: { ($0.key?.path ?? "") < ($1.key?.path ?? "") }) {
        guard let folder else {
            tests.forEach { say("  \($0.test) is in no package or Xcode scheme, so it maps to its own file") }
            continue
        }
        covered.merge(try SwiftPMCoverage(package: folder, root: root).covered(tests.map(\.test))) { $1 }
    }
    let golang = GoCoverage(root: root)
    let goTests = declarations.filter {
        $0.path.hasPrefix("requirements/") && $0.path.hasSuffix("_test.go") && !$0.path.dropFirst(13).contains("/")
    }
    if golang.exists, !goTests.isEmpty { covered.merge(try golang.covered(goTests.map(\.test))) { $1 } }
} catch {
    say("\(error)")
    say("a requirement test failed, so its coverage is unknown")
    exit(1)
}

// The catalog's own files are left out, so a page's commit dates only the acceptances that cover its code.
// A test that covered nothing else maps to its own file.
let catalog = StorybookCatalogFiles(in: root, excluding: options.excluded)
catalog.unmatched.forEach { say("  --exclude \($0) names no tracked file; spell it from the repo's root") }
var map: [String: Set<String>] = [:]
for test in declarations {
    let files = (covered[test.test] ?? []).filter { !catalog.contains($0) }
    map[test.id, default: []].formUnion(files.isEmpty ? [test.path] : files)
}
try StorybookCoverageMap.json(map).write(to: output, atomically: true, encoding: .utf8)
say("Wrote \(sources([output.path(percentEncoded: false)], root: root).first ?? output.path): \(map.count) acceptances")
