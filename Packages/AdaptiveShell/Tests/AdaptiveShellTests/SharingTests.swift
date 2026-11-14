import AdaptiveShell
import CoreGraphics
import Testing
import UITestingLibrary

/// Requirement 0013: the sidebar sits beside the pane, and the empty pane shows the app's words.
extension AdaptiveShellTests {
    @MainActor
    @Suite struct Sharing {
        @Test func test0013_1() async throws {
            let launch = try Launch(Launch.duoInner)
            try await launch.user.sees(.text(DiaryApp.prompt))
            let entry = try await launch.element(.button(DiaryApp.entry)).frame
            let prompt = try await launch.element(.text(DiaryApp.prompt)).frame
            #expect(entry.maxX <= prompt.minX, "the sidebar covers the pane's prompt")
            try launch.quits()
        }

        @Test func test0013_3() async throws {
            let launch = try Launch(Launch.duoInner)
            let before = try await launch.element(.identifier(DiaryApp.sidebarEdge)).frame
            try await launch.user.drags(
                .identifier(DiaryApp.sidebarEdge), by: CGVector(dx: 80, dy: 0), speed: .slow)
            let after = try await launch.element(.identifier(DiaryApp.sidebarEdge)).frame
            #expect(after.midX > before.midX + 40, "the sidebar kept its width")
            try launch.quits()
        }

        @Test func test0013_2() async throws {
            let launch = try Launch(.pad, systemPrompt: true)
            try await launch.user.sees(.text(DiaryApp.prompt))
            try await launch.user.sees(.text(DiaryApp.promptMessage))
            try launch.quits()
        }
    }
}
