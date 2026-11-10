import Foundation
import Navigation
import Testing
import UITestingLibrary

/// Requirement 0002: every link lands through one door, or says why it opened nothing.
extension NavigationTests {
    @MainActor
    @Suite struct Opening {
        /// Renders the app, then opens `link` as `onOpenURL` would.
        private func open(_ link: String, in diary: Diary = Diary()) throws -> Session {
            let session = try Session(diary)
            diary.open(try #require(URL(string: link)))
            return session
        }

        @Test func test0002_1() async throws {
            let session = try open("example://day/2026-11-09")
            try await session.user.sees(.text("Day 2026-11-09"))
            try session.screen.close()
        }

        @Test func test0002_2() async throws {
            let session = try open("other://day/2026-11-09")
            try await session.user.sees(.text("Today"))
            try await session.user.doesNotSee(.text("Not Found"))
            try session.screen.close()
        }

        @Test func test0002_3() async throws {
            let gone = UUID()
            let diary = Diary(path: [.settings])
            diary.deleted = [.entry(gone)]
            let session = try open("example://entry/\(gone.uuidString)", in: diary)
            try await session.user.sees(.text("Not Found"))
            try await session.user.sees(.text("Preferences"))
            try session.screen.close()
        }

        @Test func test0002_4() async throws {
            // A slash inside a segment survives the round trip.
            let shared = try #require(ExampleRoute.links.url(for: .day("2026/11/09")))
            let session = try open(shared.absoluteString)
            try await session.user.sees(.text("Day 2026/11/09"))
            try session.screen.close()
        }

        @Test func test0002_5() async throws {
            let session = try open("Example://DAY/2026-11-09")
            try await session.user.sees(.text("Day 2026-11-09"))
            try session.screen.close()
        }
    }
}
