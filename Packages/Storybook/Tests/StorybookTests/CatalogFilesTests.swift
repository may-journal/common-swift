// cspell:ignore spi
#if os(macOS)
    import Foundation
    import StorybookHistoryKit
    import Testing

    /// Requirement 0016: the coverage map leaves out the Storybook catalog's own files.
    @Suite struct CatalogFiles {
        /// An app laid out as the may-* apps are: screens beside a folder of pages, their entry and a helper.
        /// One screen imports `Storybook` for its entry and holds its own page; another holds a `#Preview`.
        static let app = [
            "src/App/RootView.swift": """
                import Storybook
                import SwiftUI

                struct RootView: View {
                    var body: some View { DiaryView().storybookEntry(.debug) }
                }

                let rootPage = BookPage(title: "0001.2 root") { RootView() }
                """,
            "src/UI/DiaryView.swift": """
                import SwiftUI

                struct DiaryView: View {
                    var body: some View { Text("Diary") }
                }

                #Preview("0001.1 today") { DiaryView() }
                """,
            "src/Storybook/0001-Diary.swift": """
                @_spi(Pages) import Storybook
                import StorybookKit

                let diaryPage = BookPage(title: "0001.1 today") { PageHost { DiaryView() } }
                """,
            "src/Storybook/AppStorybook.swift": """
                @testable import Storybook // the catalog's entry

                let configuration = StorybookConfiguration(pages: { [diaryPage] })
                """,
            "src/Storybook/PageHost.swift": """
                import SwiftUI

                struct PageHost<Content: View>: View {
                    @ViewBuilder let content: () -> Content
                    var body: some View { content().padding() }
                }
                """,
            "Sources/Storybook/StorybookCatalog.swift": """
                import StorybookKit

                public struct Catalog { let pages: [BookPage] }
                """,
            "src/Fixtures/Samples.swift": "let samples = [\"Sam\"]\n"
        ]

        /// A git repo in a temporary folder whose index tracks the app's files, as the tool reads them.
        static func repo() throws -> URL {
            let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
            for (path, text) in app {
                let file = folder.appending(path: path)
                try FileManager.default.createDirectory(
                    at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
                try text.write(to: file, atomically: true, encoding: .utf8)
            }
            for arguments in [["init", "-q"], ["add", "-A"]] {
                let git = try Process.run(URL(filePath: "/usr/bin/git"), arguments: ["-C", folder.path] + arguments)
                git.waitUntilExit()
                #expect(git.terminationStatus == 0, "git \(arguments.joined(separator: " ")) failed")
            }
            return folder
        }

        @Test func test0016_1() throws {
            let repo = try Self.repo()
            defer { try? FileManager.default.removeItem(at: repo) }
            let catalog = StorybookCatalogFiles(in: repo)
            #expect(
                catalog.paths
                    == ["src/Storybook/0001-Diary.swift", "src/Storybook/AppStorybook.swift",
                        "src/Storybook/PageHost.swift"])
            // Screens stay, and so does the package's own code, which never imports its own module.
            let screens = ["src/App/RootView.swift", "src/UI/DiaryView.swift"]
            #expect(screens.allSatisfy { !catalog.contains($0) }, "the map left out a screen")
            #expect(
                !catalog.contains("Sources/Storybook/StorybookCatalog.swift"), "the map left out the package code")
        }

        @Test func test0016_2() throws {
            let repo = try Self.repo()
            defer { try? FileManager.default.removeItem(at: repo) }
            let catalog = StorybookCatalogFiles(in: repo, excluding: ["./src/Fixtures/"])
            #expect(catalog.unmatched.isEmpty)
            #expect(catalog.contains("src/Fixtures/Samples.swift"))
            #expect(catalog.contains("src/Storybook/PageHost.swift"))
            // A prefix names a folder or a file, never the start of a longer name.
            #expect(!StorybookCatalogFiles(in: repo, excluding: ["src/U"]).contains("src/UI/DiaryView.swift"))
            #expect(!catalog.contains("src/UI/DiaryView.swift"))
            // A path spelled from elsewhere names nothing, so the tool can say so.
            let elsewhere = repo.appending(path: "src/Fixtures").path(percentEncoded: false)
            #expect(StorybookCatalogFiles(in: repo, excluding: [elsewhere]).unmatched == [elsewhere])
        }
    }
#endif
