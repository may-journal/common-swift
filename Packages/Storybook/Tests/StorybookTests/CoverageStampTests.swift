// cspell:ignore gpgsign pbxproj xccov
#if os(macOS)
    import Foundation
    import StorybookCoverageScope
    import Testing

    /// Requirement 0017: the StorybookCoverage tool skips a current map and passes xcodebuild arguments on.
    /// Each test runs the built tool on a repo in a temporary folder, as an app's `make coverage` does.
    @Suite(.storybookCoverage) struct CoverageStamp {
        /// A map the tool would never write, so a run that leaves it proves the run skipped.
        static let marker = "{\n  \"0000.1\": []\n}\n"

        /// A repo that ignores the map, as each app's does, committed once.
        static func app() throws -> Checkout {
            try Checkout([
                ".gitignore": "docs/requirements/coverage.json\n", "README.md": "Diary\n",
                "docs/requirements/0001-diary.md": "# 0001 Diary\n"
            ])
        }

        @Test func test0017_1() throws {
            let repo = try Self.app()
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            #expect(try Tool.run(in: repo).status == 0)
            try repo.writes(["docs/requirements/coverage.json": Self.marker])
            let again = try Tool.run(in: repo)
            #expect(again.status == 0)
            #expect(again.log.contains("is current for HEAD"))
            #expect(try Tool.map(of: repo) == Self.marker)
            // Other arguments could map other tests, so they run it again.
            #expect(try Tool.run(in: repo, ["--exclude", "README.md"]).status == 0)
            #expect(try Tool.map(of: repo) == "{}\n")
        }

        @Test func test0017_2() throws {
            let repo = try Self.app()
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            #expect(try Tool.run(in: repo).status == 0)
            // A new test file git does not track yet still changes what the map should list.
            try repo.writes(["Tests/DiaryTests.swift": "import Testing\n"])
            for _ in 1...2 {
                try repo.writes(["docs/requirements/coverage.json": Self.marker])
                #expect(try Tool.run(in: repo).status == 0)
                #expect(try Tool.map(of: repo) == "{}\n")
            }
            try FileManager.default.removeItem(at: repo.folder.appending(path: "Tests"))
            try repo.writes(["README.md": "Diary, edited\n", "docs/requirements/coverage.json": Self.marker])
            #expect(try Tool.run(in: repo).status == 0)
            #expect(try Tool.map(of: repo) == "{}\n")
        }

        @Test func test0017_3() throws {
            // A project's requirement test outside any package, its name spelled in pieces so that
            // this repo's own search for requirement tests skips it.
            let repo = try Checkout([
                ".gitignore": "docs/requirements/coverage.json\n", "App.xcodeproj/project.pbxproj": "// project\n",
                "Requirements/DiaryTests.swift": "func test\("0001")_1() {}\n"
            ])
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            let xcodebuild = try FakeXcodebuild()
            defer { try? FileManager.default.removeItem(at: xcodebuild.folder) }
            let extra = ["-allowProvisioningUpdates", "-xcconfig", "config/requirements.xcconfig"]
            let result = try Tool.run(in: repo, ["--scheme", "App", "--"] + extra, path: xcodebuild.folder)
            #expect(result.status == 0, "\(result.log)")
            let calls = try xcodebuild.calls()
            // It builds, lists the tests and runs them once; the fake records no profile, so the test
            // runs alone.
            #expect(calls.count == 4)
            #expect(calls.allSatisfy { Array($0.suffix(extra.count)) == extra })
            #expect(try Tool.map(of: repo).contains("Requirements/DiaryTests.swift"))
        }
    }

    /// The built `storybook-coverage` tool, beside this test bundle in the build folder.
    enum Tool {
        final class Marker {}

        static var url: URL {
            Bundle(for: Marker.self).bundleURL.deletingLastPathComponent().appending(path: "storybook-coverage")
        }

        /// Runs the tool on `repo` from its root, with `path` ahead of the PATH, and returns its status and log.
        static func run(
            in repo: Checkout, _ arguments: [String] = [], path: URL? = nil
        ) throws -> (status: Int32, log: String) {
            let process = Process()
            process.executableURL = url
            process.arguments = arguments
            process.currentDirectoryURL = repo.folder
            var environment = ProcessInfo.processInfo.environment
            if let path { environment["PATH"] = "\(path.path(percentEncoded: false)):\(environment["PATH"] ?? "")" }
            process.environment = environment
            let log = Pipe()
            process.standardError = log
            process.standardOutput = log
            try process.run()
            let data = log.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            return (process.terminationStatus, String(bytes: data, encoding: .utf8) ?? "")
        }

        static func map(of repo: Checkout) throws -> String {
            try String(contentsOf: repo.folder.appending(path: "docs/requirements/coverage.json"), encoding: .utf8)
        }
    }

    /// A repo in a temporary folder with one commit of `files`, which a test then edits in place.
    struct Checkout {
        let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)

        init(_ files: [String: String]) throws {
            try writes(files)
            for arguments in [["init", "-q"], ["add", "-A"], ["commit", "-q", "-m", "feat: diary"]] {
                let git = try Process.run(
                    URL(filePath: "/usr/bin/git"),
                    arguments: ["-C", folder.path, "-c", "user.name=Tester", "-c", "user.email=tester@example.com",
                                "-c", "commit.gpgsign=false"] + arguments)
                git.waitUntilExit()
                #expect(git.terminationStatus == 0, "git \(arguments.joined(separator: " ")) failed")
            }
        }

        /// Writes each file at its repo path without committing it.
        func writes(_ files: [String: String]) throws {
            for (path, text) in files {
                let file = folder.appending(path: path)
                try FileManager.default.createDirectory(
                    at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
                try text.write(to: file, atomically: true, encoding: .utf8)
            }
        }
    }

    /// An `xcodebuild` on the PATH that records each call's arguments, one per line, beside an `xcrun` for xccov.
    private struct FakeXcodebuild {
        let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)

        init() throws {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            // The scheme lists the repo's one test, and xccov reports that it covered nothing.
            let listing = #"{"values":[{"enabledTests":[{"identifier":"AppTests/DiaryTests/test"#
                + "0001_1()\"}]}]}"
            let xcodebuild = """
                #!/bin/sh
                printf '%s\\037' "$@" >> "$(dirname "$0")/calls"
                printf '\\n' >> "$(dirname "$0")/calls"
                while [ $# -gt 0 ]; do
                  if [ "$1" = -test-enumeration-output-path ]; then
                    mkdir -p "$(dirname "$2")" && printf '%s' '\(listing)' > "$2"
                  fi
                  shift
                done
                """
            for (name, script) in [("xcodebuild", xcodebuild), ("xcrun", "#!/bin/sh\necho '{\"targets\":[]}'\n")] {
                let file = folder.appending(path: name)
                try script.write(to: file, atomically: true, encoding: .utf8)
                try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: file.path)
            }
        }

        /// Each call's arguments, in order.
        func calls() throws -> [[String]] {
            let text = try String(contentsOf: folder.appending(path: "calls"), encoding: .utf8)
            return text.split(separator: "\n").map { line in
                line.split(separator: "\u{1F}", omittingEmptySubsequences: false).dropLast().map(String.init)
            }
        }
    }
#endif
