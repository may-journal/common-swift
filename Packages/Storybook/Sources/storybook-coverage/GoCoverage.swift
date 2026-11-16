// cspell:ignore coverprofile
import Foundation

/// Runs the Go requirement tests in the repo's `requirements/` module one at a time, each with a
/// coverage profile.
struct GoCoverage {
    let root: URL

    var module: URL { root.appending(path: "requirements") }

    /// Whether the repo has the module.
    var exists: Bool { FileManager.default.fileExists(atPath: module.appending(path: "go.mod").path) }

    /// Each test's covered repo files, keyed by the test's name, leaving out Go test files.
    func covered(_ tests: [String]) throws -> [String: [String]] {
        let manifest = try String(contentsOf: module.appending(path: "go.mod"), encoding: .utf8)
        let name = manifest.split(separator: "\n").first { $0.hasPrefix("module ") }
            .map { String($0.dropFirst("module ".count)).trimmingCharacters(in: .whitespaces) } ?? ""
        let profile = FileManager.default.temporaryDirectory
            .appending(path: "storybook-coverage-\(UUID().uuidString).out")
        defer { try? FileManager.default.removeItem(at: profile) }
        var found: [String: [String]] = [:]
        for test in tests {
            say("  \(test)")
            try run(
                ["go", "test", "-C", module.path(percentEncoded: false), "-count=1", "-run", "^\(test)$",
                 "-coverprofile=\(profile.path(percentEncoded: false))", "."])
            // Profile lines read "module/path.go:1.2,3.4 statements count"; a count above 0 ran.
            let lines = try String(contentsOf: profile, encoding: .utf8).split(separator: "\n").dropFirst()
            found[test] = lines.compactMap { line -> String? in
                let fields = line.split(separator: " ")
                guard let count = fields.last.flatMap({ Int($0) }), count > 0, let location = fields.first,
                    let file = location.split(separator: ":").first
                else { return nil }
                let path = file.hasPrefix("\(name)/") ? "requirements/" + file.dropFirst(name.count + 1) : String(file)
                return path.hasSuffix("_test.go") ? nil : path
            }
        }
        return found
    }
}
