// cspell:ignore coverprofile
import Foundation
import Synchronization

/// Runs the Go requirement tests in the repo's `requirements/` module, each in its own `go test`
/// with a coverage profile, several at once. Go cannot zero its counters per test beside
/// `t.Parallel()`, so the processes run side by side instead of one run recording each test.
struct GoCoverage {
    let root: URL

    var module: URL { root.appending(path: "requirements") }

    /// Whether the repo has the module.
    var exists: Bool { FileManager.default.fileExists(atPath: module.appending(path: "go.mod").path) }

    /// Whether the module holds Go code besides its tests, the only code a Go test can cover.
    var hasStatements: Bool {
        let walk = FileManager.default.enumerator(atPath: module.path)
        while let path = walk?.nextObject() as? String {
            if path.hasSuffix(".go"), !path.hasSuffix("_test.go"), !path.hasPrefix("vendor/") { return true }
        }
        return false
    }

    /// Each test's covered repo files, keyed by the test's name, leaving out Go test files. A module
    /// with nothing but tests covers nothing, so its tests map to their own files without running.
    func covered(_ tests: [String]) throws -> [String: [String]] {
        guard hasStatements else {
            say("  requirements/ has no Go code besides its tests, so its \(tests.count) tests map to their files")
            return Dictionary(uniqueKeysWithValues: tests.map { ($0, []) })
        }
        let manifest = try String(contentsOf: module.appending(path: "go.mod"), encoding: .utf8)
        let name = manifest.split(separator: "\n").first { $0.hasPrefix("module ") }
            .map { String($0.dropFirst("module ".count)).trimmingCharacters(in: .whitespaces) } ?? ""
        say("  \(tests.count) Go tests, \(Self.width) at a time")
        let found = Mutex<[String: [String]]>([:])
        let failure = Mutex<(any Error)?>(nil)
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = Self.width
        for test in tests {
            queue.addOperation {
                do {
                    let files = try covered(test, module: name)
                    found.withLock { $0[test] = files }
                } catch {
                    failure.withLock { $0 = $0 ?? error }
                }
            }
        }
        queue.waitUntilAllOperationsAreFinished()
        if let error = failure.withLock({ $0 }) { throw error }
        return found.withLock { $0 }
    }

    /// Half the Mac's cores, leaving the rest to the tests' own work.
    static var width: Int { max(1, ProcessInfo.processInfo.activeProcessorCount / 2) }

    private func covered(_ test: String, module name: String) throws -> [String] {
        let profile = FileManager.default.temporaryDirectory
            .appending(path: "storybook-coverage-\(UUID().uuidString).out")
        defer { try? FileManager.default.removeItem(at: profile) }
        try run(
            ["go", "test", "-C", module.path(percentEncoded: false), "-count=1", "-run", "^\(test)$",
             "-coverprofile=\(profile.path(percentEncoded: false))", "."])
        // Profile lines read "module/path.go:1.2,3.4 statements count"; a count above 0 ran.
        let lines = try String(contentsOf: profile, encoding: .utf8).split(separator: "\n").dropFirst()
        return lines.compactMap { line -> String? in
            let fields = line.split(separator: " ")
            guard let count = fields.last.flatMap({ Int($0) }), count > 0, let location = fields.first,
                let file = location.split(separator: ":").first
            else { return nil }
            let path = file.hasPrefix("\(name)/") ? "requirements/" + file.dropFirst(name.count + 1) : String(file)
            return path.hasSuffix("_test.go") ? nil : path
        }
    }
}
