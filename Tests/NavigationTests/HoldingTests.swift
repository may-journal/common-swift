import Navigation
import Testing
import UITestingLibrary

/// Requirement 0003: a request heard before the screen is ready waits, then opens once.
extension NavigationTests {
    @MainActor
    @Suite struct Holding {
        /// Holds each request before the app launches, then waits for the screen to load.
        private func launch(holding requests: [ExampleRoute]) async throws -> Diary {
            let diary = Diary()
            requests.forEach(diary.requests.hold)
            let session = try Session(diary)
            try await session.user.sees(.text("Day 2026-11-09"))
            try session.screen.close()
            return diary
        }

        @Test func test0003_1() async throws {
            let diary = try await launch(holding: [.day("2026-11-09")])
            #expect(diary.router.top == .day("2026-11-09"))
        }

        @Test func test0003_2() async throws {
            let diary = try await launch(holding: [.day("2026-11-09")])
            #expect(diary.requests.take() == nil)
            #expect(diary.router.path == [.day("2026-11-09")])
        }

        @Test func test0003_3() async throws {
            let diary = try await launch(holding: [.day("2026-11-08"), .day("2026-11-09")])
            #expect(diary.router.path == [.day("2026-11-09")])
        }
    }
}
