// cspell:ignore gpgsign
#if os(macOS)
    import Foundation
    import StorybookCoverageScope
    import Testing

    /// Requirement 0018: the StorybookCoverage tool runs each suite once and maps again only what changed.
    /// Each test runs the built tool on a Swift package in a temporary repo, as an app's `make coverage` does.
    @Suite(.storybookCoverage) struct CoverageScope {
        /// A package on this checkout's scope: two tests under the trait cover a file each, and an `unscoped`
        /// third covers the first. Names are spelled in pieces, so this repo's search for requirement tests skips them.
        static func diary(unscoped: Bool = false, adding more: String = "") throws -> Checkout {
            let scope = URL(filePath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
                .deletingLastPathComponent().appending(path: "Sources/StorybookCoverageScope")
            var files = [
                ".gitignore": ".build/\ndocs/requirements/coverage.json\n",
                "docs/requirements/0001-diary.md": "# 0001 Diary\n",
                "Package.swift": """
                    // swift-tools-version: 6.3
                    import PackageDescription

                    let package = Package(
                        name: "Diary", platforms: [.macOS("27.0")],
                        targets: [
                            .target(name: "Diary"), .target(name: "StorybookCoverageScope"),
                            .testTarget(name: "DiaryTests", dependencies: ["Diary", "StorybookCoverageScope"])
                        ])

                    """,
                "Sources/Diary/Pages.swift": "public func pages() -> Int { 1 }\n",
                "Sources/Diary/Words.swift": "public func words() -> Int { 2 }\n",
                "Tests/DiaryTests/DiaryTests.swift": """
                    import Diary
                    import StorybookCoverageScope
                    import Testing

                    @Suite(.storybookCoverage) struct DiaryTests {
                        @Test func test\("0001")_1() { #expect(pages() == 1) }

                        // The trait again, inside the root suite's, records the test once.
                        @Suite(.storybookCoverage) struct Words {
                            @Test func test\("0001")_2() { #expect(words() == 2) }
                        }
                    }

                    """ + (unscoped ? Self.unscoped : "") + more
            ]
            for name in try FileManager.default.contentsOfDirectory(atPath: scope.path) {
                files["Sources/StorybookCoverageScope/\(name)"] = try String(
                    contentsOf: scope.appending(path: name), encoding: .utf8)
            }
            return try Checkout(files)
        }

        /// A suite without the trait, whose one test covers the same file as the first.
        static let unscoped = "@Suite struct Unscoped {\n  @Test func test\("0001")_3() { #expect(pages() == 1) }\n}\n"

        /// A test with arguments, whose two cases cover a file each.
        static let parameterized = """
            @Suite(.storybookCoverage) struct Counting {
              @Test(arguments: [1, 2]) func test\("0001")_3(count: Int) {
                #expect((count == 1 ? pages() : words()) == count)
              }
            }

            """

        static let pages = "Sources/Diary/Pages.swift", words = "Sources/Diary/Words.swift"

        /// The rows the diary's first map holds, without its unscoped test.
        static let rows = ["0001.1": [pages], "0001.2": [words]]

        @Test func test0018_1() throws {
            let repo = try Self.diary()
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            let result = try Tool.run(in: repo)
            #expect(result.status == 0, "\(result.log)")
            #expect(result.log.contains("Running 2 tests once"))
            // Neither recorded test ran alone after.
            #expect(
                !result.log.contains("  test\("0001")_1\n") && !result.log.contains("  test\("0001")_2\n"),
                "\(result.log)")
            let map = try Tool.rows(of: repo)
            #expect(map["0001.1"] == Self.rows["0001.1"], "\(map)")
            #expect(map["0001.2"] == Self.rows["0001.2"], "\(map)")
        }

        @Test func test0018_2() throws {
            let repo = try Self.diary(unscoped: true)
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            let result = try Tool.run(in: repo)
            #expect(result.status == 0, "\(result.log)")
            #expect(result.log.contains("test\("0001")_3 has no profile from that run, so it runs alone"))
            #expect(try Tool.rows(of: repo)["0001.3"] == [Self.pages])
        }

        @Test func test0018_3() throws {
            let repo = try Self.diary()
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            #expect(try Tool.run(in: repo).status == 0)
            try repo.commits([Self.words: "// Counts the words.\npublic func words() -> Int { 2 }\n"])
            let result = try Tool.run(in: repo)
            #expect(result.status == 0, "\(result.log)")
            #expect(result.log.contains("Mapping 1 of 2 acceptances again"))
            #expect(result.log.contains("Running 1 test once"))
            #expect(try Tool.rows(of: repo) == Self.rows)
        }

        @Test func test0018_4() throws {
            let repo = try Self.diary()
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            #expect(try Tool.run(in: repo).status == 0)
            let package = try String(contentsOf: repo.folder.appending(path: "Package.swift"), encoding: .utf8)
            let changes = [
                Change(reason: "since Package.swift changes the build") {
                    try repo.commits(["Package.swift": package + "// Built with coverage.\n"])
                },
                Change(reason: "since Sources/Diary/Notes.swift is code that no row of the earlier map lists") {
                    try repo.commits(["Sources/Diary/Notes.swift": "public func notes() -> Int { 3 }\n"])
                },
                Change(reason: "since Sources/Diary/Words.json may change what a test runs, and no row lists it") {
                    try repo.commits(["Sources/Diary/Words.json": "[\"diary\"]\n"])
                },
                Change(reason: "since 2 of 2 acceptances changed") {
                    try repo.commits([
                        Self.pages: "// Counts the pages.\npublic func pages() -> Int { 1 }\n",
                        Self.words: "// Counts the words.\npublic func words() -> Int { 2 }\n"
                    ])
                },
                // A run on a dirty tree leaves no stamp, so the run after it maps every acceptance.
                Change(reason: "") {
                    try repo.writes([Self.words: "// Words, unsaved.\npublic func words() -> Int { 2 }\n"])
                },
                Change(reason: "since no earlier map was stamped on a clean tree") { try repo.commits([:]) },
                Change(reason: "since --full asks for it", arguments: ["--full"]) {}
            ]
            for change in changes {
                try change.edit()
                let result = try Tool.run(in: repo, change.arguments)
                #expect(result.status == 0, "\(result.log)")
                if !change.reason.isEmpty {
                    #expect(result.log.contains("Mapping every acceptance, \(change.reason)"), "\(result.log)")
                    #expect(result.log.contains("Running 2 tests once"))
                }
                #expect(try Tool.rows(of: repo) == Self.rows)
            }
        }

        @Test func test0018_5() throws {
            // A Go test that fails if it runs, so a clean run proves that none ran.
            let repo = try Checkout([
                ".gitignore": "docs/requirements/coverage.json\n",
                "requirements/go.mod": "module example.com/diary/requirements\n\ngo 1.24\n",
                "requirements/0001_test.go": """
                    package requirements

                    import "testing"

                    func Test\("0001")_1(t *testing.T) { t.Fatal("ran") }

                    """
            ])
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            let result = try Tool.run(in: repo)
            #expect(result.status == 0, "\(result.log)")
            #expect(result.log.contains("requirements/ has no Go code besides its tests"))
            #expect(try Tool.rows(of: repo) == ["0001.1": ["requirements/0001_test.go"]])
        }
    }

    extension CoverageScope {
        @Test func test0018_6() throws {
            let repo = try Self.diary(adding: Self.parameterized)
            defer { try? FileManager.default.removeItem(at: repo.folder) }
            // Xcode names the test `test0001_3(count:)`, labels included.
            let result = try Tool.run(in: repo, ["--xcode", repo.folder.path])
            #expect(result.status == 0, "\(result.log)")
            #expect(result.log.contains("Running 3 tests once"), "\(result.log)")
            #expect(try Tool.rows(of: repo)["0001.3"] == [Self.pages, Self.words])
        }
    }

    extension CoverageScope {
        @Test func test0018_7() throws {
            // The second case fails, by an expectation or by throwing, and the first leaves a profile.
            let expecting = Self.parameterized.replacing("== count)", with: "== 1)")
            let throwing = expecting.replacing("Int) {", with: "Int) throws {")
                .replacing("#expect(", with: "try #require(")
            for failing in [expecting, throwing] {
                let repo = try Self.diary(adding: failing)
                defer { try? FileManager.default.removeItem(at: repo.folder) }
                let result = try Tool.run(in: repo)
                #expect(result.status != 0, "\(result.log)")
                #expect(result.log.contains("test\("0001")_3 has no profile from that run, so it runs alone"))
                #expect(result.log.contains("a requirement test failed"), "\(result.log)")
                let map = repo.folder.appending(path: "docs/requirements/coverage.json")
                #expect(!FileManager.default.fileExists(atPath: map.path))
            }
        }
    }

    /// One step of requirement 0018.4: an edit to the repo, then the reason a full run gives, if any.
    private struct Change {
        let reason: String
        var arguments: [String] = []
        let edit: () throws -> Void
    }

    extension Tool {
        /// The map the tool wrote into `repo`, as rows of files.
        static func rows(of repo: Checkout) throws -> [String: [String]] {
            let data = try Data(contentsOf: repo.folder.appending(path: "docs/requirements/coverage.json"))
            return try JSONSerialization.jsonObject(with: data) as? [String: [String]] ?? [:]
        }
    }

    extension Checkout {
        /// Writes each file at its repo path and commits every change, so the tree is clean again.
        func commits(_ files: [String: String]) throws {
            try writes(files)
            for arguments in [["add", "-A"], ["commit", "-q", "--allow-empty", "-m", "fix: diary"]] {
                let git = try Process.run(
                    URL(filePath: "/usr/bin/git"),
                    arguments: ["-C", folder.path, "-c", "user.name=Tester", "-c", "user.email=tester@example.com",
                                "-c", "commit.gpgsign=false"] + arguments)
                git.waitUntilExit()
                #expect(git.terminationStatus == 0, "git \(arguments.joined(separator: " ")) failed")
            }
        }
    }
#endif
