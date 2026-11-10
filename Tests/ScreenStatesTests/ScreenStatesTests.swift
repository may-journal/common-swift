import Observation
import ScreenStates
import SwiftUI
import Testing
import UITestingLibrary

/// Runs every screen test one at a time, since rendering a screen closes the one before.
@MainActor
@Suite(.serialized) struct ScreenStatesTests {}

/// The example app's data: a shopping list that loads, fails or comes back empty.
@Observable
@MainActor
final class Groceries {
    var state: LoadState<[String]>
    /// What the next load brings back.
    var next: LoadState<[String]> = .loaded(["Milk", "Eggs"])
    var invited = false

    init(_ state: LoadState<[String]>) {
        self.state = state
    }

    func reload() {
        state = next
    }
}

/// A list screen as an app writes it: one load-state switch, an empty state with an action.
struct GroceryScreen: View {
    let groceries: Groceries

    var body: some View {
        LoadStateView(groceries.state, retry: groceries.reload) {
            StatusView(
                symbol: "cart", title: "Nothing to buy",
                message: "Items you add show up here.",
                action: StatusAction("Share the list") { groceries.invited = true })
        } content: { items in
            VStack { ForEach(items, id: \.self) { Text($0) } }
        }
    }
}

/// Renders the grocery screen and acts on it as a person would.
struct Session {
    let screen: Screen
    let user: User

    @MainActor
    init(@ViewBuilder _ content: () -> some View) throws {
        screen = try Screen.render(content: content)
        user = User(screen)
    }
}

/// A row with state of its own that shows as a placeholder while it refreshes.
struct RefreshingRow: View {
    @State private var refreshing = false

    var body: some View {
        VStack {
            Counter().loadingPlaceholder(refreshing, label: "Loading row")
            Button("Refresh") { refreshing = true }
            Button("Done") { refreshing = false }
        }
    }
}

/// A count the row keeps in its own state.
struct Counter: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Button("Count") { count += 1 }
            Text("Count \(count)")
        }
    }
}
