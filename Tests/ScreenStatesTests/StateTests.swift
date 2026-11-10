import ScreenStates
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0006: every screen that loads says where its data stands and offers a way on.
extension ScreenStatesTests {
    @MainActor
    @Suite struct States {
        @Test func test0006_1() async throws {
            let session = try Session { GroceryScreen(groceries: Groceries(.loading)) }
            try await session.user.sees(.text("Loading"))
            try await session.user.doesNotSee(.text("Milk"))
            try await session.user.doesNotSee(.text("Nothing to buy"))
            try await session.user.doesNotSee(.button("Try Again"))
            try session.screen.close()
        }

        @Test func test0006_2() async throws {
            let groceries = Groceries(.failed("The list could not sync."))
            let session = try Session { GroceryScreen(groceries: groceries) }
            try await session.user.sees(.text("Something went wrong"))
            try await session.user.sees(.text("The list could not sync."))
            try await session.user.sees(.button("Try Again"))
            try session.screen.close()
        }

        @Test func test0006_3() async throws {
            let groceries = Groceries(.failed("The list could not sync."))
            let session = try Session { GroceryScreen(groceries: groceries) }
            try await session.user.taps(.button("Try Again"))
            try await session.user.sees(.text("Milk"))
            try await session.user.doesNotSee(.text("Something went wrong"))
            try session.screen.close()
        }

        @Test func test0006_4() async throws {
            let session = try Session { GroceryScreen(groceries: Groceries(.loaded([]))) }
            try await session.user.sees(.text("Nothing to buy"))
            try await session.user.sees(.text("Items you add show up here."))
            try session.screen.close()
        }

        @Test func test0006_5() async throws {
            let groceries = Groceries(.loaded([]))
            let session = try Session { GroceryScreen(groceries: groceries) }
            try await session.user.taps(.button("Share the list"))
            #expect(groceries.invited)
            try session.screen.close()
        }

        @Test func test0006_6() async throws {
            let session = try Session { GroceryScreen(groceries: Groceries(.loaded(["Milk"]))) }
            try await session.user.sees(.text("Milk"))
            try await session.user.doesNotSee(.text("Nothing to buy"))
            try await session.user.doesNotSee(.text("Loading"))
            try session.screen.close()
        }

        @Test func test0006_8() async throws {
            let session = try Session { StatusPill("Syncing") }
            try await session.user.sees(.text("Syncing, in progress"))
            try session.screen.close()
        }

        @Test func test0006_7() async throws {
            let session = try Session { RefreshingRow() }
            try await session.user.taps(.button("Count"))
            try await session.user.taps(.button("Refresh"))
            try await session.user.sees(.text("Loading row"))
            try await session.user.doesNotSee(.text("Count 1"))
            try await session.user.taps(.button("Done"))
            try await session.user.sees(.text("Count 1"))
            try session.screen.close()
        }
    }
}
