import AdaptiveLayout
import SwiftUI
import Testing
import UITestingLibrary

/// Runs every screen test one at a time, since rendering a screen closes the one before.
@MainActor
@Suite(.serialized) struct AdaptiveLayoutTests {}

/// Says how wide it was laid out, so a test reads what the layout gave it.
struct Measured: View {
    let name: String
    @State private var width: CGFloat = 0

    var body: some View {
        Text("\(name) \(Int(width.rounded(.down)))")
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self) {
                $0.size.width
            } action: {
                width = $0
            }
    }
}

/// The example app's list and detail, as a notes app would split them.
struct NotesScreen: View {
    @State private var showsDetail = false
    @State private var starred = false
    /// The window's width, which Widen grows past the breakpoint as a person drags it.
    @State var width: CGFloat

    var body: some View {
        VStack {
            Button("Widen") { width = 1000 }
            NavigationStack {
                SplitOrStack(showsDetail: $showsDetail) {
                    VStack {
                        Text("All notes")
                        Button("Groceries") { showsDetail = true }
                        Button(starred ? "Starred" : "Star") { starred = true }
                    }
                } detail: {
                    Text("Milk and eggs")
                }
            }
            .frame(width: width)
        }
    }
}

/// A tile in a grid, identified for `ForEach`.
struct Tile: Identifiable {
    let id: Int
}

/// Renders a root at `size` and acts on it as a person would.
struct Session {
    let screen: Screen
    let user: User

    @MainActor
    init(_ size: ScreenSize, @ViewBuilder _ content: () -> some View) throws {
        screen = try Screen.render(size: size, content: content)
        user = User(screen)
    }
}
