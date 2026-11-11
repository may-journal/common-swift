import Storybook
import Testing
import UITestingLibrary

/// Requirement 0006: who sees the Storybook row at the end of Settings.
extension StorybookTests {
    @MainActor
    @Suite struct Seeing {
        @Test func test0006_1() async throws {
            let launch = try Launch(.appStore)
            try await launch.user.neverSees(.button(StorybookWords.version), for: .seconds(1))
            let version = try await launch.user.sees(.identifier("settings.version"))
            #expect(!version.has(.button))
            try await launch.user.doesNotSee(.button(StorybookWords.name))
            try launch.quits()
        }

        @Test func test0006_2() async throws {
            let launch = try Launch(.testFlight)
            try await launch.waitsForTheAnswer()
            try await launch.user.neverSees(.button(StorybookWords.name), for: .seconds(1))
            try launch.quits()
        }

        @Test func test0006_3() async throws {
            let launch = try Launch(.testFlight)
            try await launch.waitsForTheAnswer()
            try await launch.tapsVersionSevenTimes()
            try await launch.user.sees(.button(StorybookWords.name))
            try launch.quits()
        }

        @Test func test0006_4() async throws {
            let first = try Launch(.testFlight)
            try await first.waitsForTheAnswer()
            try await first.tapsVersionSevenTimes()
            try await first.user.sees(.button(StorybookWords.name))
            try first.screen.close()
            let relaunch = try Launch(.testFlight, relaunch: true)
            try await relaunch.user.sees(.button(StorybookWords.name))
            try relaunch.quits()
        }

        @Test func test0006_5() async throws {
            let launch = try Launch(.debug)
            try await launch.user.sees(.button(StorybookWords.name))
            try launch.quits()
        }

        @Test func test0006_6() async throws {
            let launch = try Launch(.testFlight, ownsVersion: true)
            try await launch.waitsForTheAnswer()
            try await launch.tapsVersionSevenTimes()
            try await launch.user.sees(.button(StorybookWords.name))
            try launch.quits()
        }
    }
}
