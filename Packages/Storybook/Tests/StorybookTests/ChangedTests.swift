import Foundation
import Storybook
import Testing
import UITestingLibrary

/// Requirement 0015: the catalog badges pages whose code is new or changed, aged at the build.
/// Each launch turns the header's freshness on, since it starts hidden.
extension StorybookTests {
    @MainActor
    @Suite struct Changed {
        static let freshness = ["--storybook-freshness", "on"]
        static let cardPage = ["--storybook", DiaryApp.cardPage] + freshness

        /// The diary card's acceptance, changed at `changed`, `commitsAgo` commits before a
        /// build made at `build`, or in its own commit at 0.
        static func history(
            changed: String, build: String = "2026-11-01T12:00:00Z", commitsAgo: Int = 2
        ) throws -> StorybookHistory {
            let acceptance = StorybookHistory.Acceptance(
                changed: try Date(changed, strategy: .iso8601), changedIn: commitsAgo == 0 ? "build" : "older",
                commitsAgo: commitsAgo, then: "it shows its long sample")
            return StorybookHistory(
                commit: "build", buildDate: try Date(build, strategy: .iso8601), acceptances: ["0008.2": acceptance])
        }

        @Test func test0015_1() async throws {
            let history = try Self.history(changed: "2026-11-01T12:00:00Z", commitsAgo: 0)
            let launch = try Launch(.debug, arguments: Self.freshness, history: history)
            try await launch.opensStorybook()
            try await launch.user.sees(.identifier("storybook.badge.new"))
            try await launch.user.sees(.text(StorybookWords.new))
            try launch.quits()
        }

        @Test func test0015_2() async throws {
            let launch = try Launch(
                .debug, arguments: Self.freshness, history: try Self.history(changed: "2026-10-30T12:00:00Z"))
            try await launch.opensStorybook()
            try await launch.user.sees(.text("Changed Oct 30"))
            try await launch.user.sees(.text("2 days before the build"))
            try await launch.user.doesNotSee(.identifier("storybook.badge.new"))
            try launch.quits()
        }

        @Test func test0015_3() async throws {
            let history = try Self.history(changed: "2025-03-04T12:00:00Z", build: "2025-03-20T12:00:00Z")
            let launch = try Launch(.debug, arguments: Self.freshness, history: history)
            try await launch.opensStorybook()
            try await launch.user.sees(.text("16 days before the build"))
            try launch.quits()
        }

        @Test func test0015_4() async throws {
            let history = try Self.history(changed: "2026-10-30T12:00:00Z")
            let launch = try Launch(.debug, arguments: Self.cardPage, history: history)
            try await launch.user.sees(.text("it shows its long sample"))
            try await launch.user.sees(.text("Changed Oct 30, 2026"))
            try launch.quits()
        }

        @Test func test0015_5() async throws {
            let launch = try Launch(.debug, arguments: Self.freshness)
            try await launch.opensStorybook()
            try await launch.user.sees(.text("sample"))
            try await launch.user.neverSees(.identifier("storybook.badge.new"), for: .seconds(1))
            try launch.quits()
        }

        @Test func test0015_8() async throws {
            let history = try Self.history(changed: "2026-10-30T12:00:00Z", commitsAgo: 3)
            let launch = try Launch(.debug, arguments: Self.cardPage, history: history)
            try await launch.user.sees(.text("3 commits ago"))
            try launch.quits()
        }
    }
}
