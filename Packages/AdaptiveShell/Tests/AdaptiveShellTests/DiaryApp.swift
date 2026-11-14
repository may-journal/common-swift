import AdaptiveShell
import CoreGraphics
import SwiftUI
import Testing
import UITestingLibrary

/// A small diary app that adopts the shell as an app maintainer does. Its entries fill the
/// sidebar, the picked entry or a prompt fills the pane, and it routes to a Settings page.
struct DiaryApp: View {
    enum Page: Hashable { case settings }

    /// Whether the app picks the stack-only shell.
    var stackOnly = false
    /// The shell's sizes, as the app sets them.
    var configuration = ShellConfiguration()
    /// Whether the empty pane is the system's prompt with the diary's words, not its own view.
    var systemPrompt = false
    @State private var path: [Page] = []
    @State private var picked: String?

    var body: some View {
        if stackOnly {
            AdaptiveShell(path: $path) { entries } page: { page($0) }
        } else {
            AdaptiveShell(path: $path, configuration: configuration) { _ in entries } pane: {
                pane
            } page: { page($0) }
        }
    }

    @ViewBuilder private var pane: some View {
        if systemPrompt {
            ShellPane(
                selection: picked, title: Self.prompt, systemImage: "book", message: Self.promptMessage
            ) { Text(Self.opened($0)) }
        } else {
            ShellPane(selection: picked) { Text(Self.opened($0)) } empty: { Text(Self.prompt) }
        }
    }

    private var entries: some View {
        List {
            Button(Self.entry) { picked = Self.entry }
            Button(Self.settings) { path.append(.settings) }
        }
        // A test's handle on the system's divider: it straddles the column's edge, and the
        // press passes through it to the split.
        .overlay(alignment: .trailing) {
            Color.clear.frame(width: 2).offset(x: 1)
                .accessibilityElement()
                .accessibilityIdentifier(Self.sidebarEdge)
                .allowsHitTesting(false)
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
    static let promptMessage = "It opens here, beside your entries."
    static func opened(_ entry: String) -> String { "Reading \(entry)" }
    static let settings = "Settings"
    static let done = "Done"
    static let settingsPage = "Reminders at nine"
    static let sidebarEdge = "sidebar edge"
}

/// One launch of the diary app at a screen size: its rendered screen and the person using it.
@MainActor
struct Launch {
    let screen: Screen
    let user: User

    /// A split narrower than 800 points, as on the Duo held upright.
    static let narrowSplit = ScreenSize(
        points: CGSize(width: 700, height: 1000), isRegularWidth: true)
    /// The iPhone Duo's inner screen, unfolded and upright.
    static let duoInner = ScreenSize(
        points: CGSize(width: 669, height: 951), isRegularWidth: true)

    init(
        _ size: ScreenSize, stackOnly: Bool = false,
        configuration: ShellConfiguration = ShellConfiguration(), systemPrompt: Bool = false
    ) throws {
        screen = try Screen.render(size: size) {
            DiaryApp(stackOnly: stackOnly, configuration: configuration, systemPrompt: systemPrompt)
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

    /// The element `query` finds on the screen now: where it is drawn and what VoiceOver says.
    func element(_ query: Query) async throws -> Element {
        let drawn = await user.reads().first(where: query.matches)
        return try #require(drawn, "\(query) is not on the screen")
    }

    func quits() throws {
        try screen.close()
    }
}
