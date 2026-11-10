import Navigation
import Testing
import UITestingLibrary

/// Requirement 0001: one path, owned by the router, that every move goes through.
extension NavigationTests {
    @MainActor
    @Suite struct Moving {
        @Test func test0001_1() async throws {
            let diary = Diary()
            let session = try Session(diary)
            try await session.user.taps(.button("Open day"))
            try await session.user.sees(.text("Day 2026-11-09"))
            #expect(diary.router.top == .day("2026-11-09"))
            try session.screen.close()
        }

        @Test func test0001_2() async throws {
            let diary = Diary(path: [.settings, .day("2026-11-09")])
            let session = try Session(diary)
            try await session.user.taps(.button("Settings"))
            try await session.user.sees(.text("Preferences"))
            #expect(diary.router.path == [.settings])
            try session.screen.close()
        }

        @Test func test0001_3() async throws {
            let diary = Diary(path: [.settings, .day("2026-11-09")])
            let session = try Session(diary)
            try await session.user.taps(.button("Home"))
            try await session.user.sees(.text("Today"))
            #expect(diary.router.path.isEmpty)
            try session.screen.close()
        }

        @Test func test0001_4() async throws {
            let diary = Diary()
            let session = try Session(diary)
            try await session.user.taps(.button("Back"))
            try await session.user.sees(.text("Today"))
            #expect(diary.router.pop() == false)
            try session.screen.close()
        }
    }
}
