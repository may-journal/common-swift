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
            // One page with a row per package, and one package per folder under Packages/.
            let page = try Launch(.pad, arguments: ["--storybook", "0012.4 Packages"])
            for package in DemoPackage.allCases {
                try await page.user.sees(.text("\(package.name): \(DemoStorybook.sample(of: package))"))
            }
            try page.quits()
            // Storybook also lists its badge pages, down to the row without history.
            let launch = try Launch(.pad)
            try await launch.opensStorybook()
            try await launch.searchesCatalog(DemoPackage.storybook.name)
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
