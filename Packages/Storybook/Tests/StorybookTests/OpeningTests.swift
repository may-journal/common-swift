import Foundation
import Storybook
import Testing
import UITestingLibrary

/// Requirement 0007: every way into the catalog opens the same one.
extension StorybookTests {
    @MainActor
    @Suite struct Opening {
        @Test func test0007_1() async throws {
            let launch = try Launch(.debug)
            try await launch.opensStorybook()
            try await launch.user.taps(.identifier("storybook.close"))
            try await launch.user.doesNotSee(.identifier("storybook.close"))
            try await launch.user.sees(.button(StorybookWords.name))
            try launch.quits()
        }

        @Test func test0007_2() async throws {
            let launch = try Launch(.debug)
            try await launch.user.sees(.button(StorybookWords.name))
            #if os(macOS)
                try await launch.user.presses("d", with: [.command, .option, .shift])
            #else
                NotificationCenter.default.post(name: .storybookShake, object: nil)
            #endif
            try await launch.user.sees(.identifier("storybook.close"))
            try launch.quits()
        }

        @Test func test0007_3() async throws {
            let launch = try Launch(.debug, arguments: ["--storybook", "DiaryCard: sample"])
            try await launch.user.sees(.text(DiaryApp.shortSample))
            try launch.quits()
        }

        @Test func test0007_4() async throws {
            let launch = try Launch(.debug)
            try await launch.opensStorybook()
            try await launch.user.sees(.text("DiaryCard"))
            try await launch.user.sees(.text("sample"))
            try launch.quits()
        }

        @Test func test0007_5() async throws {
            let launch = try Launch(.debug)
            try await launch.opensStorybook()
            try await launch.user.sees(.text("DiaryCard"))
            try await launch.user.doesNotSee(.text(DiaryApp.demoComponent))
            try launch.quits()
        }
    }
}
