import Foundation
import Storybook
import Testing
import UITestingLibrary

/// Requirement 0015: the catalog badges pages new and changed in this build.
extension StorybookTests {
    @MainActor
    @Suite struct Changed {
        /// The diary card's acceptance, added `added` days ago and changed `changed` days ago,
        /// in the commit "build" when `inBuild`.
        static func history(added: Int, changed: Int, inBuild: Bool = false) -> StorybookHistory {
            let day: TimeInterval = 24 * 60 * 60
            let now = Date.now
            let acceptance = StorybookHistory.Acceptance(
                added: now.addingTimeInterval(-Double(added) * day),
                addedIn: inBuild ? "build" : "older", changed: now.addingTimeInterval(-Double(changed) * day),
                then: "it shows its long sample")
            return StorybookHistory(commit: "build", acceptances: ["0008.2": acceptance])
        }

        @Test func test0015_1() async throws {
            let launch = try Launch(.debug, history: Self.history(added: 0, changed: 0, inBuild: true))
            try await launch.opensStorybook()
            try await launch.user.sees(.identifier("storybook.badge.new"))
            try await launch.user.sees(.text(StorybookWords.new))
            try launch.quits()
        }

        @Test func test0015_2() async throws {
            let history = Self.history(added: 30, changed: 2)
            let launch = try Launch(.debug, history: history)
            try await launch.opensStorybook()
            let changed = try #require(history.badge(for: "0008.2"))
            try await launch.user.sees(.text(StorybookWords.badge(changed)))
            try await launch.user.doesNotSee(.identifier("storybook.badge.new"))
            try launch.quits()
        }

        @Test func test0015_3() async throws {
            let history = Self.history(added: 30, changed: 30)
            let launch = try Launch(.debug, history: history)
            try await launch.opensStorybook()
            let added = try #require(history.badge(for: "0008.2"))
            try await launch.user.sees(.text(StorybookWords.badge(added)))
            try launch.quits()
        }

        @Test func test0015_4() async throws {
            let history = Self.history(added: 30, changed: 2)
            let launch = try Launch(.debug, arguments: ["--storybook", DiaryApp.cardPage], history: history)
            let acceptance = try #require(history.acceptances["0008.2"])
            try await launch.user.sees(.text("it shows its long sample"))
            try await launch.user.sees(.text(StorybookWords.dates(acceptance)))
            try launch.quits()
        }

        @Test func test0015_5() async throws {
            let launch = try Launch(.debug)
            try await launch.opensStorybook()
            try await launch.user.sees(.text("sample"))
            try await launch.user.neverSees(.identifier("storybook.badge.new"), for: .seconds(1))
            try launch.quits()
        }

        @Test func test0015_8() async throws {
            let history = Self.history(added: 30, changed: 30)
            let launch = try Launch(.debug, arguments: ["--storybook", DiaryApp.cardPage], history: history)
            let acceptance = try #require(history.acceptances["0008.2"])
            try await launch.user.sees(.text("it shows its long sample"))
            let added = acceptance.added.formatted(date: .abbreviated, time: .omitted)
            try await launch.user.sees(.text(StorybookWords.added(added)))
            try launch.quits()
        }
    }
}
