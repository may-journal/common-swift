import Foundation
import StorybookHistoryKit

/// Runs a Swift package's requirement tests one at a time with code coverage, reading the
/// llvm-cov export `swift test` writes. Its own scratch folder keeps clear of a build in progress.
struct SwiftPMCoverage {
    let package: URL
    let root: URL

    /// Each test's covered repo files, keyed by the test's name.
    func covered(_ tests: [String]) throws -> [String: [String]] {
        let scratch = package.appending(path: ".build/storybook-coverage").path(percentEncoded: false)
        let base = ["--package-path", package.path(percentEncoded: false), "--scratch-path", scratch]
        say("Building \(relative(package)) with coverage")
        try run(["swift", "build"] + base + ["--build-tests", "--enable-code-coverage", "-q"])
        let codecov = try run(["swift", "test"] + base + ["--show-codecov-path"])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        var found: [String: [String]] = [:]
        for test in tests {
            say("  \(test)")
            try run(["swift", "test"] + base + ["--skip-build", "--enable-code-coverage", "--filter", "\(test)\\("])
            found[test] = try files(URL(filePath: codecov))
        }
        return found
    }

    /// The export's files with executed lines.
    private func files(_ export: URL) throws -> [String] {
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: export)) as? [String: Any]
        let report = (json?["data"] as? [[String: Any]])?.first
        let files = (report?["files"] as? [[String: Any]] ?? []).compactMap { file -> String? in
            let lines = (file["summary"] as? [String: Any])?["lines"] as? [String: Any]
            guard let covered = lines?["covered"] as? Int, covered > 0 else { return nil }
            return file["filename"] as? String
        }
        return sources(files, root: root)
    }

    private func relative(_ folder: URL) -> String {
        sources([folder.path(percentEncoded: false)], root: root).first ?? folder.lastPathComponent
    }
}
