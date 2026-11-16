@testable import DemoKit
import Testing
import UITestingLibrary

/// Requirement 0012: the demo shows every package at work.
extension DemoKitTests {
    @MainActor
    @Suite struct Showing {
        @Test func test0012_1() async throws {
            let launch = try Launch(.pad)
            try await launch.picks(.adaptiveShell)
            try await launch.user.sees(.text(DemoWords.inPane))
            try await launch.user.sees(.identifier(DemoPackage.storybook.rowIdentifier))
            try launch.quits()
        }

        @Test func test0012_2() async throws {
            let launch = try Launch(.phone)
            try await launch.picks(.adaptiveShell)
            try await launch.user.sees(.text(DemoWords.onStack))
            try await launch.user.doesNotSee(.identifier(DemoPackage.storybook.rowIdentifier))
            try launch.quits()
        }

        @Test func test0012_3() async throws {
            let launch = try Launch(.pad)
            try await launch.opensStorybook()
            try launch.quits()
        }

        @Test func test0012_4() async throws {
            let launch = try Launch(.pad)
            try await launch.opensStorybook()
            // One page per package, and one package per folder under Packages/. A page for every
            // other acceptance lists between them, so each package is searched for.
            for package in DemoPackage.allCases {
                try await launch.searchesCatalog(package.name)
                try await launch.user.sees(.text(DemoStorybook.sample(of: package)))
            }
            // Storybook also lists its badge pages, down to the row without history.
            try await launch.user.sees(.text("No history"))
            #expect(Set(DemoPackage.allCases.map(\.name)) == Launch.packageFolders())
            try launch.quits()
        }

        @Test func test0012_5() async throws {
            let launch = try Launch(.pad)
            try await launch.picks(.storybook)
            try await launch.user.sees(.button(DemoWords.openSettings))
            try await launch.picks(.storybook)
            try await launch.user.sees(.text(DemoWords.prompt))
            try await launch.user.doesNotSee(.button(DemoWords.openSettings))
            try launch.quits()
        }
    }
}
