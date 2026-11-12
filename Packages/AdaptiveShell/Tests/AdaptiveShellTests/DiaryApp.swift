import AdaptiveShell
import CoreGraphics
import SwiftUI
import UITestingLibrary

/// A small diary app that adopts the shell as an app maintainer does. Its entries fill the
/// sidebar, the picked entry or a prompt fills the pane, and it routes to a Settings page.
struct DiaryApp: View {
    enum Page: Hashable { case settings }

    /// Whether the app picks the stack-only shell.
    var stackOnly = false
    @State private var path: [Page] = []
    @State private var picked: String?

    var body: some View {
        if stackOnly {
            AdaptiveShell(path: $path) { entries } page: { page($0) }
        } else {
            AdaptiveShell(path: $path) { _ in entries } pane: {
                ShellPane(selection: picked) { Text(Self.opened($0)) } empty: { Text(Self.prompt) }
            } page: { page($0) }
        }
    }

    private var entries: some View {
        List {
            Button(Self.entry) { picked = Self.entry }
            Button(Self.settings) { path.append(.settings) }
        }
    }

    /// The Settings page, which closes from its own Done button.
    private func page(_ page: Page) -> some View {
        VStack {
            Text(Self.settingsPage)
            Button(Self.done) { path.removeAll() }
        }
        .navigationTitle(Self.settings)
    }

    static let entry = "Kites over the dunes"
    static let prompt = "Pick an entry"
    static func opened(_ entry: String) -> String { "Reading \(entry)" }
    static let settings = "Settings"
    static let done = "Done"
    static let settingsPage = "Reminders at nine"
}

/// One launch of the diary app at a screen size: its rendered screen and the person using it.
@MainActor
struct Launch {
    let screen: Screen
    let user: User

    /// A split narrower than the width the sidebar floats below, as on the Duo held upright.
    static let narrowSplit = ScreenSize(
        points: CGSize(width: 700, height: 1000), isRegularWidth: true)

    init(_ size: ScreenSize, stackOnly: Bool = false) throws {
        screen = try Screen.render(size: size) {
            DiaryApp(stackOnly: stackOnly)
                #if os(macOS)
                    // The library sets the size class on iOS only. A Mac test window gets the
                    // size class of the phone or iPad it stands for.
                    .environment(\.horizontalSizeClass, size.isRegularWidth ? .regular : .compact)
                #endif
        }
        user = User(screen)
    }

    /// Opens Settings from the sidebar.
    func opensSettings() async throws {
        try await user.sees(.text(DiaryApp.entry))
        try await user.taps(.button(DiaryApp.settings))
        try await user.sees(.text(DiaryApp.settingsPage))
    }

    func quits() throws {
        try screen.close()
    }
}
