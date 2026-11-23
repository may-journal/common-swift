// cspell:ignore profraw xctest
import Foundation
import StorybookHistoryKit

/// Runs a Swift package's requirement tests with coverage: once for those under `.storybookCoverage`,
/// then alone for the rest. Its own scratch folder keeps clear of a build in progress.
struct SwiftPMCoverage {
    let package: URL
    let root: URL

    /// Each test's covered repo files, keyed by the test's name.
    func covered(_ tests: [String]) throws -> [String: [String]] {
        let scratch = package.appending(path: ".build/storybook-coverage")
        let base = ["--package-path", package.path(percentEncoded: false), "--scratch-path", scratch.path]
        say("Building \(relative(package)) with coverage")
        try run(["swift", "build"] + base + ["--build-tests", "--enable-code-coverage", "-q"])
        let codecov = try run(["swift", "test"] + base + ["--show-codecov-path"])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let products = URL(filePath: codecov).deletingLastPathComponent().deletingLastPathComponent()
        var found = once(tests, base: base, scratch: scratch, products: products)
        for test in tests where found[test] == nil {
            say("  \(test)")
            try run(["swift", "test"] + base + ["--skip-build", "--enable-code-coverage", "--filter", "\(test)\\("])
            found[test] = sources(executedFiles(try Data(contentsOf: URL(filePath: codecov))), root: root)
        }
        return found
    }

    /// Runs every test in one `swift test`, one at a time with live counters, and reads the profiles
    /// the scope attached. A failed test leaves none, so it runs alone after.
    private func once(_ tests: [String], base: [String], scratch: URL, products: URL) -> [String: [String]] {
        let work = scratch.appending(path: "scope")
        try? FileManager.default.removeItem(at: work)
        let attachments = work.appending(path: "attachments")
        // A profile runtime that already ran, as in a test running this tool, leaves the folder to us.
        for folder in [attachments, work.appending(path: "raw")] {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        say("Running \(tests.count) \(tests.count == 1 ? "test" : "tests") once")
        let filter = tests.map { "\($0)\\(" }.joined(separator: "|")
        let environment = ScopeProfiles.environment.merging(
            ["LLVM_PROFILE_FILE": work.appending(path: "raw/%p%c.profraw").path(percentEncoded: false)]) { $1 }
        _ = try? run(
            ["swift", "test"] + base
                + ["--skip-build", "--no-parallel", "--attachments-path", attachments.path, "--filter", filter],
            environment: environment, check: false)
        let bundles = (try? FileManager.default.contentsOfDirectory(at: products, includingPropertiesForKeys: nil))?
            .filter { $0.pathExtension == "xctest" } ?? []
        let objects = bundles.map { bundle in
            bundle.appending(path: "Contents/MacOS/\(bundle.deletingPathExtension().lastPathComponent)")
        }.filter { FileManager.default.fileExists(atPath: $0.path) }
        let found = ScopeProfiles(folder: attachments).covered(tests, objects: objects, root: root)
        tests.filter { found[$0] == nil }.forEach { say("  \($0) has no profile from that run, so it runs alone") }
        return found
    }

    private func relative(_ folder: URL) -> String {
        let path = sources([folder.path(percentEncoded: false)], root: root).first ?? folder.lastPathComponent
        return path.isEmpty ? "the repo's package" : path
    }
}
