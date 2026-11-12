import SwiftUI

/// The app's root: pages stack over the sidebar on a phone, and open beside it on a wide screen.
public struct AdaptiveShell<Page: Hashable, Sidebar: View, Pane: View, PageView: View>: View {
    @Binding private var path: [Page]
    private let configuration: ShellConfiguration
    private let splits: Bool
    private let sidebar: (ShellLayout) -> Sidebar
    private let pane: () -> Pane
    private let page: (Page) -> PageView
    @Environment(\.horizontalSizeClass) private var sizeClass

    /// A shell that splits on a wide screen. `sidebar` is told the layout it shows in, so it can
    /// add what only a phone's stack needs, such as a pushed detail.
    public init(
        path: Binding<[Page]>,
        configuration: ShellConfiguration = ShellConfiguration(),
        @ViewBuilder sidebar: @escaping (ShellLayout) -> Sidebar,
        @ViewBuilder pane: @escaping () -> Pane,
        @ViewBuilder page: @escaping (Page) -> PageView
    ) {
        _path = path
        self.configuration = configuration
        splits = true
        self.sidebar = sidebar
        self.pane = pane
        self.page = page
    }

    public var body: some View {
        if splits, ShellLayout.fitting(sizeClass) == .split {
            ShellSplit(
                path: $path, configuration: configuration, sidebar: { sidebar(.split) }, pane: pane,
                page: page)
        } else {
            NavigationStack(path: $path) {
                sidebar(.stack)
                    .navigationDestination(for: Page.self, destination: page)
            }
            .environment(\.shellLayout, .stack)
        }
    }
}

extension AdaptiveShell where Pane == EmptyView {
    /// A shell that stacks on every screen, for an app with no sidebar yet. `root` is the
    /// stack's first screen.
    public init(
        path: Binding<[Page]>,
        @ViewBuilder root: @escaping () -> Sidebar,
        @ViewBuilder page: @escaping (Page) -> PageView
    ) {
        _path = path
        configuration = ShellConfiguration()
        splits = false
        sidebar = { _ in root() }
        pane = { EmptyView() }
        self.page = page
    }
}
