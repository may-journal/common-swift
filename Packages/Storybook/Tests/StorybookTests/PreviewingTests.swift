import Storybook
import Testing
import UITestingLibrary

/// Requirement 0008: launch arguments set how every preview draws.
extension StorybookTests {
    @MainActor
    @Suite struct Previewing {
        @Test func test0008_1() async throws {
            let launch = try Launch(
                .debug, arguments: ["--storybook", "DiaryCard: sample", "--storybook-device", "duo"])
            let frame = try await launch.user.sees(.identifier("storybook.board.device"))
            #expect(frame.spoken.hasSuffix("669x951"))
            try launch.quits()
        }

        @Test func test0008_2() async throws {
            let launch = try Launch(
                .debug,
                arguments: ["--storybook", "DiaryCard: sample", "--storybook-data-length", "long"])
            try await launch.user.sees(.text(DiaryApp.longSample))
            try launch.quits()
        }
    }
}
