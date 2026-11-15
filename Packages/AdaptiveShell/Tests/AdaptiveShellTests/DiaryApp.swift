import AdaptiveShell
import CoreGraphics
import SwiftUI
import Testing
import UITestingLibrary

/// A small diary app that adopts the shell as an app maintainer does. Its entries fill the
/// sidebar, the picked entry or a prompt fills the pane, and it routes to a Settings page.
struct DiaryApp: View {
    enum Page: Hashable { case settings, about, textSize }
    /// What a sidebar row opens: the picked entry or a page.
    enum Row: Hashable { case entry, settings, about }

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

    /// The row marked while its page or entry is open; the system draws it as selected. A tap on
    /// a row toggles it through the row's own action, so a marked row closes on the next tap.
    private var rowSelection: Binding<Row?> {
        Binding {
            switch path.first {
            case .settings: .settings
            case .about: .about
            default: picked == nil ? nil : .entry
            }
        } set: { _ in }
    }

    /// A row that toggles what it opens. The list draws it selected while it is open, and
    /// VoiceOver says so.
    private func row(_ title: String, _ row: Row, toggle: @escaping () -> Void) -> some View {
        Button(title, action: toggle)
            .tag(row)
            .accessibilityAddTraits(rowSelection.wrappedValue == row ? .isSelected : [])
    }

    private var entries: some View {
        List(selection: rowSelection) {
            row(Self.entry, .entry) { picked.toggle(Self.entry) }
            row(Self.settings, .settings) { $path.toggle(.settings) }
            row(Self.about, .about) { $path.toggle(.about) }
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

    /// The Settings page, which closes from its own Done button, and the pages beside it.
    @ViewBuilder private func page(_ page: Page) -> some View {
        switch page {
        case .settings:
            VStack {
                Text(Self.settingsPage)
                Button(Self.textSize) { path.append(.textSize) }
                Button(Self.done) { path.removeAll() }
            }
            .navigationTitle(Self.settings)
        case .about:
            Text(Self.aboutPage).navigationTitle(Self.about)
        case .textSize:
            Text(Self.textSizePage).navigationTitle(Self.textSize)
        }
    }

    static let entry = "Kites over the dunes"
    static let prompt = "Pick an entry"
    static let promptMessage = "It opens here, beside your entries."
    static func opened(_ entry: String) -> String { "Reading \(entry)" }
    static let settings = "Settings"
    static let done = "Done"
    static let settingsPage = "Reminders at nine"
    static let about = "About"
    static let aboutPage = "Made for the dunes"
    static let textSize = "Text Size"
    static let textSizePage = "Larger words"
    static let back = "Back"
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

    /// Narrows the sidebar, drags its edge far past the screen's middle, then reads where the
    /// edge stopped.
    func dragsSidebarAllTheWay() async throws -> CGFloat {
        try await user.drags(
            .identifier(DiaryApp.sidebarEdge), by: CGVector(dx: -40, dy: 0), speed: .slow)
        let narrowed = try await element(.identifier(DiaryApp.sidebarEdge)).frame.minX
        try await user.drags(
            .identifier(DiaryApp.sidebarEdge), by: CGVector(dx: 500, dy: 0), speed: .slow)
        let stopped = try await element(.identifier(DiaryApp.sidebarEdge)).frame.minX
        #expect(stopped > narrowed + 20, "the sidebar never widened from \(narrowed)")
        return stopped
    }

    func quits() throws {
        try screen.close()
    }
}
