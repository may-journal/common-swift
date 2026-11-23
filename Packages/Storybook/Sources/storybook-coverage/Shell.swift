import Foundation

/// A command that failed: its words and what it printed.
struct CommandFailure: Error, CustomStringConvertible {
    let command: [String]
    let log: String

    var description: String { "\(command.joined(separator: " ")) failed:\n\(log)" }
}

/// Runs a command from the PATH in `folder`, adding `environment`, and returns its standard output.
/// Output goes to files, so a long log never blocks it, and a failure throws unless `check` is false.
@discardableResult
func run(
    _ command: [String], in folder: URL? = nil, environment: [String: String] = [:], check: Bool = true
) throws -> String {
    let work = FileManager.default.temporaryDirectory.appending(path: "storybook-coverage-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: work, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: work) }
    let out = work.appending(path: "out"), err = work.appending(path: "err")
    FileManager.default.createFile(atPath: out.path, contents: nil)
    FileManager.default.createFile(atPath: err.path, contents: nil)
    let process = Process()
    process.executableURL = URL(filePath: "/usr/bin/env")
    process.arguments = command
    process.currentDirectoryURL = folder
    if !environment.isEmpty {
        process.environment = ProcessInfo.processInfo.environment.merging(environment) { $1 }
    }
    process.standardOutput = try FileHandle(forWritingTo: out)
    process.standardError = try FileHandle(forWritingTo: err)
    try process.run()
    process.waitUntilExit()
    let stdout = (try? String(contentsOf: out, encoding: .utf8)) ?? ""
    guard process.terminationStatus == 0 || !check else {
        let stderr = (try? String(contentsOf: err, encoding: .utf8)) ?? ""
        throw CommandFailure(command: command, log: stdout + stderr)
    }
    return stdout
}

/// Writes a progress line to standard error, as the old script did.
func say(_ line: String) {
    FileHandle.standardError.write(Data("\(line)\n".utf8))
}

/// Repo-relative paths of `files` inside `root`, leaving out tests, build output and the coverage
/// scope, which runs around every test.
func sources(_ files: [String], root: URL) -> [String] {
    let prefix = root.path(percentEncoded: false).hasSuffix("/")
        ? root.path(percentEncoded: false) : root.path(percentEncoded: false) + "/"
    return files.compactMap { file in
        // Foundation resolves /private/var to /var, where the compiler keeps the real path.
        let file = file.hasPrefix("/private/") && !prefix.hasPrefix("/private/") ? String(file.dropFirst(8)) : file
        guard file.hasPrefix(prefix) else { return nil }
        let path = String(file.dropFirst(prefix.count))
        let folders = path.split(separator: "/").dropLast()
        let skipped = ["Tests", ".build", "StorybookCoverageScope"]
        return folders.contains { skipped.contains(String($0)) } ? nil : path
    }
}
