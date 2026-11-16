// cspell:ignore gpgsign
#if os(macOS)
    import Foundation
    import StorybookHistoryKit
    import Testing

    /// Requirement 0015: the StorybookHistory tool reads each acceptance's git history.
    @Suite struct History {
        /// A requirement doc with one acceptance whose Then line is `then`.
        static func doc(_ then: String, more: String = "") -> String {
            """
            # 0001 Diary

            ## Requirements

            - 0001.1
              - Given Tester opens the diary
                - When the card shows
                  - Then \(then)
            \(more)
            """
        }

        @Test func test0015_6() throws {
            let repo = try Repo()
            try repo.commits(Self.doc("it shows the date"), at: "2026-10-01T09:00:00Z")
            let second = [
                "- 0001.2", "  - Given Tester opens an empty diary", "    - When the card shows",
                "      - Then it shows a prompt"
            ].joined(separator: "\n")
            try repo.commits(Self.doc("it shows the date", more: second), at: "2026-10-05T09:00:00Z")
            try repo.renames(to: "0001-journal.md", at: "2026-10-07T09:00:00Z")
            try repo.commits(
                Self.doc("it shows the weekday", more: second), to: "0001-journal.md", at: "2026-10-09T09:00:00Z",
                committed: "2026-10-20T09:00:00Z")
            let history = try #require(StorybookHistoryReader.read(repo.folder))
            let first = try #require(history.acceptances["0001.1"])
            #expect(first.added == (try Date("2026-10-01T09:00:00Z", strategy: .iso8601)))
            #expect(first.changed == (try Date("2026-10-09T09:00:00Z", strategy: .iso8601)))
            #expect(first.then == "it shows the weekday")
            let added = try #require(history.acceptances["0001.2"])
            #expect(added.changed == added.added)
            #expect(history.badge(for: "0001.2") == .added(added.added))
            #expect(history.badge(for: "0001.1") == .changed(first.changed))
        }

        @Test func test0015_7() throws {
            let origin = try Repo()
            try origin.commits(Self.doc("it shows the date"), at: "2026-10-01T09:00:00Z")
            try origin.commits(Self.doc("it shows the weekday"), at: "2026-10-09T09:00:00Z")
            let shallow = try Repo(cloning: origin, depth: 1)
            #expect(StorybookHistoryReader.read(shallow.folder) == nil)
        }
    }

    /// A git repo in a temporary folder, committed to as a maintainer does.
    private struct Repo {
        let folder: URL

        init() throws {
            folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try run(["init", "-q", "-b", "main"])
        }

        init(cloning origin: Repo, depth: Int) throws {
            folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
            try Repo.git(
                ["clone", "-q", "--depth", "\(depth)", "file://\(origin.folder.path(percentEncoded: false))",
                 folder.path(percentEncoded: false)], in: FileManager.default.temporaryDirectory)
        }

        /// Writes the diary's requirement doc as `name` and commits it, written at `date`.
        /// A rebased commit was committed later, at `committed`.
        func commits(_ doc: String, to name: String = "0001-diary.md", at date: String, committed: String? = nil)
            throws {
            let docs = folder.appending(path: "docs/requirements")
            try FileManager.default.createDirectory(at: docs, withIntermediateDirectories: true)
            try doc.write(to: docs.appending(path: name), atomically: true, encoding: .utf8)
            try run(["add", "-A"])
            try run(["commit", "-q", "-m", "docs(requirements): diary"], date: date, committed: committed)
        }

        /// Renames the diary's requirement doc to `name` and commits it at `date`.
        func renames(to name: String, at date: String) throws {
            try run(["mv", "docs/requirements/0001-diary.md", "docs/requirements/\(name)"])
            try run(["commit", "-q", "-m", "docs(requirements): rename diary"], date: date)
        }

        private func run(_ arguments: [String], date: String? = nil, committed: String? = nil) throws {
            try Repo.git(arguments, in: folder, date: date, committed: committed)
        }

        private static func git(
            _ arguments: [String], in folder: URL, date: String? = nil, committed: String? = nil
        ) throws {
            let process = Process()
            process.executableURL = URL(filePath: "/usr/bin/git")
            process.currentDirectoryURL = folder
            process.arguments =
                ["-c", "user.name=Tester", "-c", "user.email=tester@example.com", "-c", "commit.gpgsign=false"]
                + arguments
            var environment = ProcessInfo.processInfo.environment
            if let date {
                environment["GIT_AUTHOR_DATE"] = date
                environment["GIT_COMMITTER_DATE"] = committed ?? date
            }
            process.environment = environment
            try process.run()
            process.waitUntilExit()
            #expect(process.terminationStatus == 0, "git \(arguments.joined(separator: " ")) failed")
        }
    }
#endif
