// cspell:ignore gpgsign
#if os(macOS)
    import Foundation
    import StorybookHistoryKit
    import Testing

    /// Requirements 0015 and 0020: the StorybookHistory tool dates each acceptance from the code its
    /// test covers, and records each doc's title.
    @Suite struct History {
        /// A requirement doc whose two acceptances end with these Then lines.
        static func doc(_ then: String) -> String {
            """
            # 0001 Diary

            ## Requirements

            - 0001.1
              - Given Tester opens the diary
                - When the card shows
                  - Then \(then)
            - 0001.2
              - Given Tester opens an empty diary
                - When the card shows
                  - Then it shows a prompt
            - 0001.3
              - Given Tester opens the diary at night
                - When the card shows
                  - Then it dims
            - 0001.4
              - Given Tester opens the diary offline
                - When the card shows
                  - Then it says so

            """
        }

        /// A Swift test file declaring 0001.3's test, which the coverage map leaves out. The name is
        /// spelled in pieces, so this repo's own search for requirement tests never finds it here.
        static func nightTest(_ body: String) -> String {
            "func test\("0001")_3() { \(body) }\n"
        }

        /// 0001.1's test covers two source files; 0001.2's covers none, so it maps to its test.
        static let coverage = """
            {
              "0001.1": ["Sources/Card.swift", "Sources/Diary.swift"],
              "0001.2": ["Tests/DiaryTests.swift"]
            }
            """

        static func date(_ text: String) throws -> Date {
            try Date(text, strategy: .iso8601)
        }

        @Test func test0015_6() throws {
            let repo = try Repo()
            // The map is generated and ignored by git, so it sits in the working tree uncommitted.
            try repo.writes(["docs/requirements/coverage.json": Self.coverage])
            try repo.commits(
                [
                    ".gitignore": "docs/requirements/coverage.json\n",
                    "docs/requirements/0001-diary.md": Self.doc("it shows the date"),
                    "Sources/Card.swift": "let card = 1\n", "Sources/Diary.swift": "let diary = 1\n",
                    "Tests/DiaryTests.swift": "let test = 1\n", "Tests/NightTests.swift": Self.nightTest("")
                ], at: "2026-10-01T09:00:00Z")
            try repo.commits(["Sources/Card.swift": "let card = 2\n"], at: "2026-10-05T09:00:00Z")
            // Rebased: written on Oct 9, committed on Oct 20.
            try repo.commits(
                ["Sources/Diary.swift": "let diary = 2\n"], at: "2026-10-09T09:00:00Z",
                committed: "2026-10-20T09:00:00Z")
            let rebased = try repo.head()
            try repo.commits(
                ["docs/requirements/0001-diary.md": Self.doc("it shows the weekday"),
                 "Tests/NightTests.swift": Self.nightTest("dims()")], at: "2026-10-12T09:00:00Z")
            try repo.commits(["Tests/DiaryTests.swift": "let test = 2\n"], at: "2026-10-15T09:00:00Z")
            let build = try repo.head()

            let history = try #require(StorybookHistoryReader.read(repo.folder))
            #expect(history.commit == build)
            #expect(history.buildDate == (try Self.date("2026-10-15T09:00:00Z")))
            let card = try #require(history.acceptances["0001.1"])
            #expect(card.changed == (try Self.date("2026-10-09T09:00:00Z")))
            #expect(card.changedIn == rebased)
            #expect(card.commitsAgo == 2)
            #expect(card.then == "it shows the weekday")
            #expect(history.badge(for: "0001.1") == .changed(card.changed, age: .seconds(6 * 24 * 60 * 60)))
            let prompt = try #require(history.acceptances["0001.2"])
            #expect(prompt.commitsAgo == 0)
            #expect(history.badge(for: "0001.2") == .new)
            // Missing from the map, 0001.3 is dated by its test's file; 0001.4 has no test, so no badge.
            let night = try #require(history.acceptances["0001.3"])
            #expect(night.changed == (try Self.date("2026-10-12T09:00:00Z")))
            #expect(night.commitsAgo == 1)
            #expect(history.acceptances["0001.4"] == nil)

            // A repo with no map at all dates each acceptance by its test's file alone.
            let unmapped = try Repo()
            try unmapped.commits(
                ["docs/requirements/0001-diary.md": Self.doc("it shows the date"),
                 "Tests/NightTests.swift": Self.nightTest("")], at: "2026-10-01T09:00:00Z")
            let bare = try #require(StorybookHistoryReader.read(unmapped.folder))
            #expect(bare.badge(for: "0001.3") == .new)
            #expect(bare.acceptances.keys.sorted() == ["0001.3"])
        }

        @Test func test0020_5() throws {
            let repo = try Repo()
            try repo.commits(
                [
                    "docs/requirements/0001-diary.md": Self.doc("it shows the date"),
                    "docs/requirements/0012-night-mode.md": "# 0012 Reading the diary at night\n",
                    "docs/requirements/template.md": "# NNNN Title\n"
                ], at: "2026-10-01T09:00:00Z")
            let history = try #require(StorybookHistoryReader.read(repo.folder))
            #expect(history.requirements == ["0001": "Diary", "0012": "Reading the diary at night"])
        }

        @Test func test0015_7() throws {
            let origin = try Repo()
            try origin.commits(
                ["docs/requirements/0001-diary.md": Self.doc("it shows the date")], at: "2026-10-01T09:00:00Z")
            try origin.commits(
                ["docs/requirements/0001-diary.md": Self.doc("it shows the weekday")], at: "2026-10-09T09:00:00Z")
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

        /// Writes each file at its repo path without committing it, as the coverage tool writes its map.
        func writes(_ files: [String: String]) throws {
            for (path, text) in files {
                let file = folder.appending(path: path)
                try FileManager.default.createDirectory(
                    at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
                try text.write(to: file, atomically: true, encoding: .utf8)
            }
        }

        /// Writes each file at its repo path and commits them, written at `date`. A rebased commit
        /// was committed later, at `committed`.
        func commits(_ files: [String: String], at date: String, committed: String? = nil) throws {
            try writes(files)
            try run(["add", "-A"])
            try run(["commit", "-q", "-m", "feat: diary"], date: date, committed: committed)
        }

        /// The hash of the commit checked out.
        func head() throws -> String {
            try Repo.git(["rev-parse", "HEAD"], in: folder)
        }

        private func run(_ arguments: [String], date: String? = nil, committed: String? = nil) throws {
            try Repo.git(arguments, in: folder, date: date, committed: committed)
        }

        /// Runs git in `folder` and returns what it printed, trimmed.
        @discardableResult private static func git(
            _ arguments: [String], in folder: URL, date: String? = nil, committed: String? = nil
        ) throws -> String {
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
            let output = Pipe()
            process.standardOutput = output
            try process.run()
            let data = output.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            #expect(process.terminationStatus == 0, "git \(arguments.joined(separator: " ")) failed")
            return (String(bytes: data, encoding: .utf8) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
#endif
