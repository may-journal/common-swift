import Storybook
import Testing
import UITestingLibrary

/// Requirement 0008: launch arguments set how every preview draws.
extension StorybookTests {
    @MainActor
    @Suite struct Previewing {
        @Test func test0008_1() async throws {
            let launch = try Launch(
                .debug, arguments: ["--storybook", DiaryApp.cardPage, "--storybook-device", "duo"])
            let frame = try await launch.user.sees(.identifier("storybook.board.device"))
            #expect(frame.spoken.hasSuffix("669x951"))
            try launch.quits()
        }

        @Test func test0008_2() async throws {
            let launch = try Launch(
                .debug,
                arguments: ["--storybook", DiaryApp.cardPage, "--storybook-data-length", "long"])
            try await launch.user.sees(.text(DiaryApp.longSample))
            try launch.quits()
        }

        @Test func test0008_3() async throws {
            let history = try Changed.history(changed: "2026-11-01T12:00:00Z", commitsAgo: 0)
            let launch = try Launch(.debug, history: history)
            try await launch.opensStorybook()
            try await launch.user.sees(.text("0008.2"))
            try await launch.user.sees(.text("sample"))
            try await launch.user.neverSees(.text(StorybookWords.new), for: .seconds(1))
            try launch.quits()
        }

        @Test func test0008_4() async throws {
            let history = try Changed.history(changed: "2026-10-30T12:00:00Z")
            let first = try Launch(.debug, arguments: Changed.freshness, history: history)
            try await first.opensStorybook()
            try first.screen.close()
            let relaunch = try Launch(.debug, relaunch: true, history: history)
            try await relaunch.opensStorybook()
            try await relaunch.user.sees(.text("Changed Oct 30"))
            try relaunch.quits()
        }
    }
}
