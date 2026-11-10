import AdaptiveLayout
import SwiftUI
import Testing
import Theme
import UITestingLibrary

/// Requirement 0007: each screen lays out for the width it has, in the app's sizes.
extension AdaptiveLayoutTests {
    @MainActor
    @Suite struct Layout {
        private func grid() -> some View {
            AdaptiveGrid((1...4).map(Tile.init), minimumWidth: 120) { tile in
                Measured(name: "Tile \(tile.id)")
            }
        }

        @Test func test0007_1() async throws {
            let session = try Session(.pad) { NotesScreen(width: 1000) }
            try await session.user.doesNotSee(.text("Milk and eggs"))
            try await session.user.taps(.button("Groceries"))
            try await session.user.sees(.text("All notes"))
            try await session.user.sees(.text("Milk and eggs"))
            try session.screen.close()
        }

        @Test func test0007_2() async throws {
            let session = try Session(.phone) { NotesScreen(width: 400) }
            try await session.user.sees(.text("All notes"))
            try await session.user.doesNotSee(.text("Milk and eggs"))
            try await session.user.taps(.button("Groceries"))
            try await session.user.sees(.text("Milk and eggs"))
            try await session.user.doesNotSee(.text("All notes"))
            try session.screen.close()
        }

        @Test func test0007_3() async throws {
            let session = try Session(.pad) { NotesScreen(width: 400) }
            try await session.user.taps(.button("Star"))
            try await session.user.taps(.button("Groceries"))
            try await session.user.doesNotSee(.text("All notes"))
            try await session.user.taps(.button("Widen"))
            try await session.user.sees(.button("Starred"))
            try await session.user.sees(.text("Milk and eggs"))
            try session.screen.close()
        }

        @Test func test0007_4() async throws {
            let session = try Session(.pad) { Measured(name: "Column").readableColumn() }
            try await session.user.sees(.text("Column 720"))
            try session.screen.close()
        }

        @Test func test0007_5() async throws {
            let session = try Session(.phone) { Measured(name: "Column").readableColumn() }
            try await session.user.sees(.text("Column 370"))
            try session.screen.close()
        }

        @Test func test0007_6() async throws {
            let session = try Session(.phone) { grid() }
            try await session.user.sees(.text("Tile 1 128"))
            try session.screen.close()
        }

        @Test func test0007_7() async throws {
            let session = try Session(.pad) { grid() }
            try await session.user.sees(.text("Tile 4 121"))
            try session.screen.close()
        }

        @Test func test0007_8() async throws {
            let session = try Session(.phone) {
                Measured(name: "Card").card().theme(Theme(spacing: Spacing(medium: 14)))
            }
            try await session.user.sees(.text("Card 374"))
            try session.screen.close()
        }
    }
}
