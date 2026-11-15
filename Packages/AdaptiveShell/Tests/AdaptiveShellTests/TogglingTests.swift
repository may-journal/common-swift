import AdaptiveShell
import Testing
import UITestingLibrary

/// Requirement 0014: tapping a sidebar row again closes what it opened, and Back stays.
extension AdaptiveShellTests {
    @MainActor
    @Suite struct Toggling {
        @Test func test0014_1() async throws {
            let launch = try Launch(.pad)
            try await launch.opensSettings()
            try await launch.user.taps(.button(DiaryApp.settings))
            try await launch.user.sees(.text(DiaryApp.prompt))
            try await launch.user.doesNotSee(.text(DiaryApp.settingsPage))
            try launch.quits()
        }

        @Test func test0014_2() async throws {
            let launch = try Launch(.pad)
            try await launch.opensSettings()
            try await launch.user.taps(.button(DiaryApp.textSize))
            try await launch.user.sees(.text(DiaryApp.textSizePage))
            try await launch.user.taps(.button(DiaryApp.settings))
            try await launch.user.sees(.text(DiaryApp.prompt))
            try await launch.user.doesNotSee(.text(DiaryApp.textSizePage))
            try launch.quits()
        }

        @Test func test0014_3() async throws {
            let launch = try Launch(.pad)
            try await launch.user.taps(.button(DiaryApp.about))
            try await launch.user.sees(.text(DiaryApp.aboutPage))
            try await launch.user.taps(.button(DiaryApp.settings))
            try await launch.user.sees(.text(DiaryApp.settingsPage))
            try await launch.user.doesNotSee(.text(DiaryApp.aboutPage))
            try await launch.user.sees(.button(DiaryApp.back))
            try await launch.user.goesBack()
            try await launch.user.sees(.text(DiaryApp.prompt))
            try launch.quits()
        }

        @Test func test0014_4() async throws {
            let launch = try Launch(.pad)
            try await launch.user.taps(.button(DiaryApp.entry))
            try await launch.user.sees(.text(DiaryApp.opened(DiaryApp.entry)))
            try await launch.user.taps(.button(DiaryApp.entry))
            try await launch.user.sees(.text(DiaryApp.prompt))
            try await launch.user.doesNotSee(.text(DiaryApp.opened(DiaryApp.entry)))
            try launch.quits()
        }

        @Test func test0014_5() async throws {
            let launch = try Launch(.pad)
            try await launch.opensSettings()
            try await launch.user.sees(.role(.selected, DiaryApp.settings))
            try launch.quits()
        }

        @Test func test0014_6() async throws {
            let launch = try Launch(.pad)
            try await launch.user.taps(.button(DiaryApp.entry))
            try await launch.user.sees(.role(.selected, DiaryApp.entry))
            try launch.quits()
        }

        @Test func test0014_7() async throws {
            let launch = try Launch(.phone)
            try await launch.opensSettings()
            try await launch.user.sees(.button(DiaryApp.back))
            try await launch.user.goesBack()
            try await launch.user.sees(.text(DiaryApp.entry))
            try launch.quits()
        }

        @Test func test0014_8() async throws {
            let launch = try Launch(Launch.narrowSplit, configuration: Fitting.hidesBelow800)
            try await launch.opensSettings()
            try await launch.user.doesNotSee(.text(DiaryApp.entry))
            try await launch.user.sees(.button(DiaryApp.back))
            try await launch.user.goesBack()
            try await launch.user.sees(.text(DiaryApp.prompt))
            try launch.quits()
        }
    }
}
