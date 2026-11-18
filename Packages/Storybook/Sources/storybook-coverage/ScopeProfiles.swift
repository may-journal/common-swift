// cspell:ignore profraw profdata xcresulttool xcresult xctest covmap dsym
import Foundation
import Synchronization

/// The raw profiles the StorybookCoverageScope product attached in one run of a suite, by test, and
/// what each test covered. A test the scope did not record is left out, so the tool runs it alone.
struct ScopeProfiles {
    /// Each test's raw profiles, keyed by the test's name.
    private(set) var tests: [String: [URL]] = [:]
    /// What ran before the first test, such as the app's launch, which every test's profile adds.
    private(set) var launch: [URL] = []

    /// The environment a run passes to its tests, so the scope records them.
    static let environment = ["TEST_RUNNER_STORYBOOK_COVERAGE": "1"]

    /// The profiles `swift test --attachments-path` wrote into `folder`.
    init(folder: URL) {
        for name in (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? [] {
            add(folder.appending(path: name), named: name)
        }
    }

    /// The profiles `xcresulttool export attachments` wrote into `folder`, named by its manifest.
    init(export folder: URL) {
        let file = folder.appending(path: "manifest.json")
        let manifest = try? JSONSerialization.jsonObject(with: Data(contentsOf: file))
        for test in manifest as? [[String: Any]] ?? [] {
            for attachment in test["attachments"] as? [[String: Any]] ?? [] {
                guard let file = attachment["exportedFileName"] as? String,
                    let name = attachment["suggestedHumanReadableName"] as? String
                else { continue }
                add(folder.appending(path: file), named: name)
            }
        }
    }

    /// Files the scope named: `storybook-coverage-test-<process>-<order>-<file>--<test>--.profraw`, or
    /// `storybook-coverage-launch-<process>-<file>.profraw`. Xcode adds a number and an ID before the
    /// extension, so a name is searched rather than matched whole.
    private mutating func add(_ file: URL, named name: String) {
        if let match = name.firstMatch(of: /storybook-coverage-test-\d+-\d+-\d+--(\w+?)--/) {
            tests[String(match.1), default: []].append(file)
        } else if name.contains(/storybook-coverage-launch-\d+-\d+/) {
            launch.append(file)
        }
    }

    /// Each recorded test's covered repo files, merging its profiles with the launch's, then reading
    /// them against `objects`. Several convert at once; a test that fails to convert is left out.
    func covered(_ wanted: [String], objects: [URL], root: URL) -> [String: [String]] {
        let names = wanted.filter { tests[$0] != nil }
        guard !names.isEmpty, !objects.isEmpty else { return [:] }
        let found = Mutex<[String: [String]]>([:])
        DispatchQueue.concurrentPerform(iterations: names.count) { index in
            let name = names[index]
            guard let files = try? convert((tests[name] ?? []) + launch, objects: objects, root: root) else {
                say("  \(name)'s profile did not convert")
                return
            }
            found.withLock { $0[name] = files }
        }
        return found.withLock { $0 }
    }

    private func convert(_ profiles: [URL], objects: [URL], root: URL) throws -> [String] {
        let merged = FileManager.default.temporaryDirectory
            .appending(path: "storybook-coverage-\(UUID().uuidString).profdata")
        defer { try? FileManager.default.removeItem(at: merged) }
        try run(
            ["xcrun", "llvm-profdata", "merge", "-sparse", "-o", merged.path(percentEncoded: false)]
                + profiles.map { $0.path(percentEncoded: false) })
        let paths = objects.map { $0.path(percentEncoded: false) }
        let export = try run(
            ["xcrun", "llvm-cov", "export", "-summary-only", "-instr-profile", merged.path(percentEncoded: false),
             paths[0]] + paths.dropFirst().flatMap { ["-object", $0] })
        return sources(executedFiles(Data(export.utf8)), root: root)
    }

    /// The binaries with coverage records in an Xcode build's `Products`, such as an app's code and frameworks.
    /// With no app, a package's scheme links its code into the test bundles, so those count.
    static func objects(in products: URL) -> [URL] {
        let keys: [URLResourceKey] = [.isRegularFileKey, .isSymbolicLinkKey]
        guard let walk = FileManager.default.enumerator(at: products, includingPropertiesForKeys: keys) else {
            return []
        }
        var found: Set<URL> = []
        for case let file as URL in walk {
            if file.pathExtension == "dSYM" {
                walk.skipDescendants()
                continue
            }
            let values = try? file.resourceValues(forKeys: Set(keys))
            guard values?.isRegularFile == true, values?.isSymbolicLink != true, file.pathExtension != "o",
                hasCoverage(file)
            else { continue }
            found.insert(file.resolvingSymlinksInPath())
        }
        let inTests = { (file: URL) in file.path.contains(".xctest/") }
        let hasApp = found.contains { $0.path.contains(".app/") && !inTests($0) }
        return found.filter { !hasApp || !inTests($0) }.sorted { $0.path < $1.path }
    }

    /// Whether a Mach-O file's load commands, at its start, name the coverage mapping section.
    private static func hasCoverage(_ file: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: file) else { return false }
        defer { try? handle.close() }
        guard let head = try? handle.read(upToCount: 64 * 1024), head.count > 4,
            [0xCF, 0xFA, 0xED, 0xFE] == Array(head.prefix(4))
        else { return false }
        return head.range(of: Data("__llvm_covmap".utf8)) != nil
    }
}

/// The files with executed lines in an `llvm-cov export` report, as `swift test` writes too.
func executedFiles(_ export: Data) -> [String] {
    let json = try? JSONSerialization.jsonObject(with: export) as? [String: Any]
    let report = (json?["data"] as? [[String: Any]])?.first
    return (report?["files"] as? [[String: Any]] ?? []).compactMap { file -> String? in
        let lines = (file["summary"] as? [String: Any])?["lines"] as? [String: Any]
        guard let covered = lines?["covered"] as? Int, covered > 0 else { return nil }
        return file["filename"] as? String
    }
}
