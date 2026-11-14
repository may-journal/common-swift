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
                .identifier(DiaryApp.sidebarEdge), by: CGVector(dx: -40, dy: 0), speed: .slow)
            let after = try await launch.element(.identifier(DiaryApp.sidebarEdge)).frame
            #expect(after.midX < before.midX - 20, "the sidebar kept its width")
            try launch.quits()
        }

        @Test func test0013_4() async throws {
            let launch = try Launch(Launch.duoInner)
            let edge = try await launch.dragsSidebarAllTheWay()
            #expect(abs(edge - 669 * 0.5) <= 4, "the sidebar stopped at \(edge), not half the screen")
            try launch.quits()
        }

        @Test func test0013_5() async throws {
            let launch = try Launch(
                Launch.duoInner, configuration: ShellConfiguration(sidebarMaxFraction: 0.6))
            let edge = try await launch.dragsSidebarAllTheWay()
            #expect(abs(edge - 669 * 0.6) <= 4, "the sidebar stopped at \(edge), not six tenths")
            try launch.quits()
        }

        @Test func test0013_8() {
            // A 614-point split in the Duo's 669-point window, its 55-point rail outside the safe
            // area, beside a 1194-point window.
            let own = ShellConfiguration.windowWidth(fitting: 614, among: [1194, 669])
            #expect(own == 669, "the shell measured a \(own)-point window, not its own")
            let column = ShellConfiguration().sidebarColumn(in: own)
            #expect(column.max == 334.5, "the sidebar may go to \(column.max), not the middle")
        }

        @Test func test0013_6() {
            let border = ShellConfiguration().sidebarBorder
            #expect(border.drawnWidth(displayScale: 3) == 1.0 / 3, "the default line is not one pixel")
        }

        @Test func test0013_7() {
            let hidden = ShellConfiguration(sidebarBorder: .hidden).sidebarBorder
            #expect(hidden.drawnWidth(displayScale: 3) == nil, "a hidden border still draws")
            let wide = ShellConfiguration(sidebarBorder: SidebarBorder(width: 2)).sidebarBorder
            #expect(wide.drawnWidth(displayScale: 3) == 2, "the border ignored the app's width")
        }

        @Test func test0013_2() async throws {
            let launch = try Launch(.pad, systemPrompt: true)
            try await launch.user.sees(.text(DiaryApp.prompt))
            try await launch.user.sees(.text(DiaryApp.promptMessage))
            try launch.quits()
        }
    }
}
