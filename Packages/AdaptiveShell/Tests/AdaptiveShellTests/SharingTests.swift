import AdaptiveShell
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

        @Test func test0013_2() async throws {
            let launch = try Launch(.pad, systemPrompt: true)
            try await launch.user.sees(.text(DiaryApp.prompt))
            try await launch.user.sees(.text(DiaryApp.promptMessage))
            try launch.quits()
        }
    }
}
