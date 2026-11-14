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
            try await launch.user.sees(.button(DemoPackage.storybook.name))
            try launch.quits()
        }

        @Test func test0012_2() async throws {
            let launch = try Launch(.phone)
            try await launch.picks(.adaptiveShell)
            try await launch.user.sees(.text(DemoWords.onStack))
            try await launch.user.doesNotSee(.button(DemoPackage.storybook.name))
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
            try await launch.user.sees(.text(DemoStorybook.paneSample))
            try await launch.user.sees(.text(DemoStorybook.lengthSample))
            try launch.quits()
        }
    }
}
