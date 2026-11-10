import Foundation
import Navigation
import Testing
import UITestingLibrary

/// Requirement 0004: no exit drops a draft without asking Save, Discard or Cancel.
extension NavigationTests {
    @MainActor
    @Suite struct Leaving {
        /// Renders an open entry, writes a draft when `drafted`, and taps Close.
        private func leave(_ diary: Diary, drafted: Bool = true) async throws -> (Screen, User) {
            let session = try Session(diary)
            if drafted { try await session.user.taps(.button("Write")) }
            try await session.user.taps(.button("Close"))
            return (session.screen, session.user)
        }

        private func entry() -> Diary { Diary(path: [.entry(UUID())]) }

        @Test func test0004_1() async throws {
            let (screen, user) = try await leave(entry(), drafted: false)
            try await user.sees(.text("Today"))
            try screen.close()
        }

        @Test func test0004_2() async throws {
            let (screen, user) = try await leave(entry())
            try await user.sees(.text("Unsaved entry"))
            try await user.sees(.text("Entry"))
            try screen.close()
        }

        @Test func test0004_3() async throws {
            let (screen, user) = try await leave(entry())
            try await user.taps(.button("Cancel"))
            try await user.doesNotSee(.text("Unsaved entry"))
            try await user.sees(.text("Lunch by the river"))
            try screen.close()
        }

        @Test func test0004_4() async throws {
            let diary = entry()
            let (screen, user) = try await leave(diary)
            try await user.taps(.button("Discard"))
            try await user.sees(.text("Today"))
            #expect(diary.saved == nil)
            try screen.close()
        }

        @Test func test0004_5() async throws {
            let diary = entry()
            let (screen, user) = try await leave(diary)
            try await user.taps(.button("Save"))
            try await user.sees(.text("Today"))
            #expect(diary.saved == "Lunch by the river")
            try screen.close()
        }

        @Test func test0004_6() async throws {
            let diary = entry()
            diary.saveFails = true
            let (screen, user) = try await leave(diary)
            try await user.taps(.button("Save"))
            try await user.sees(.text("Save failed"))
            try await user.sees(.text("Lunch by the river"))
            #expect(diary.router.path.count == 1)
            try screen.close()
        }

        @Test func test0004_7() async throws {
            let diary = entry()
            let session = try Session(diary)
            try await session.user.taps(.button("Write"))
            diary.open(try #require(ExampleRoute.links.url(for: .settings)))
            try await session.user.sees(.text("Unsaved entry"))
            try await session.user.doesNotSee(.text("Preferences"))
            try await session.user.taps(.button("Discard"))
            try await session.user.sees(.text("Preferences"))
            try session.screen.close()
        }

        @Test func test0004_8() async throws {
            let entry = Draft()
            var left: [Exit] = []
            let leaving = LeaveGuard<Exit>(
                hasUnsavedWork: { entry.unsaved }, perform: { left.append($0) })
            leaving.request(.back)
            try await leaving.saveThenLeave {
                leaving.reset()
                entry.unsaved = false
            }
            #expect(left.isEmpty)
            #expect(leaving.pending == nil)
        }
    }
}

/// A draft whose saved state the guard reads.
@MainActor
private final class Draft {
    var unsaved = true
}
