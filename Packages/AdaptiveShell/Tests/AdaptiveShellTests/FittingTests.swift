import AdaptiveShell
import Testing
import UITestingLibrary

/// Requirement 0010: the shell fits the sidebar, pane and pages to the screen's width.
extension AdaptiveShellTests {
    @MainActor
    @Suite struct Fitting {
        @Test func test0010_1() async throws {
            let launch = try Launch(.phone)
            try await launch.opensSettings()
            try await launch.user.doesNotSee(.text(DiaryApp.entry))
            try launch.quits()
        }

        @Test func test0010_2() async throws {
            let launch = try Launch(.pad)
            try await launch.opensSettings()
            try await launch.user.sees(.text(DiaryApp.entry))
            try launch.quits()
        }

        @Test func test0010_3() async throws {
            let launch = try Launch(Launch.narrowSplit)
            try await launch.opensSettings()
            try await launch.user.sees(.text(DiaryApp.entry))
            try launch.quits()
        }

        /// The diary hides its sidebar for a page on screens narrower than 800 points.
        static let hidesBelow800 = ShellConfiguration(pageHidesSidebarBelow: 800)

        @Test func test0010_4() async throws {
            let launch = try Launch(Launch.narrowSplit, configuration: Self.hidesBelow800)
            try await launch.opensSettings()
            try await launch.user.doesNotSee(.text(DiaryApp.entry))
            try await launch.user.taps(.button(DiaryApp.done))
            try await launch.user.sees(.text(DiaryApp.entry))
            try launch.quits()
        }

        @Test func test0010_5() async throws {
            let launch = try Launch(.pad, stackOnly: true)
            try await launch.opensSettings()
            try await launch.user.doesNotSee(.text(DiaryApp.entry))
            try launch.quits()
        }

        @Test func test0010_6() async throws {
            let launch = try Launch(.pad)
            try await launch.user.sees(.text(DiaryApp.prompt))
            try launch.quits()
        }

        @Test func test0010_7() async throws {
            let launch = try Launch(.pad)
            try await launch.user.taps(.button(DiaryApp.entry))
            try await launch.user.sees(.text(DiaryApp.opened(DiaryApp.entry)))
            try await launch.user.doesNotSee(.text(DiaryApp.prompt))
            try launch.quits()
        }

        @Test func test0010_8() async throws {
            let launch = try Launch(Launch.narrowSplit, configuration: Self.hidesBelow800)
            try await launch.opensSettings()
            try await launch.user.doesNotSee(.text(DiaryApp.entry))
            try launch.quits()
        }
    }
}
