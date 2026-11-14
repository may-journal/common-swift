import SwiftUI

/// The wide layout: the sidebar in its column, and the pane with its own stack of pages.
/// `AdaptiveShell` draws it wherever the width is not compact; a Mac-only app may use it alone.
public struct ShellSplit<Page: Hashable, Sidebar: View, Pane: View, PageView: View>: View {
    @Binding private var path: [Page]
    private let configuration: ShellConfiguration
    private let sidebar: () -> Sidebar
    private let pane: () -> Pane
    private let page: (Page) -> PageView

    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
    /// The whole window's width, a side rail included: the sidebar may take its fraction of it.
    @State private var width: CGFloat = 0
    /// The width inside the safe area, which the pane's narrowest fits within.
    @State private var insetWidth: CGFloat = 0
    /// The sidebar's place before a page moved it aside, restored on Back.
    @State private var visibilityBeforePage: NavigationSplitViewVisibility?

    public init(
        path: Binding<[Page]>,
        configuration: ShellConfiguration = ShellConfiguration(),
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder pane: @escaping () -> Pane,
        @ViewBuilder page: @escaping (Page) -> PageView
    ) {
        _path = path
        self.configuration = configuration
        self.sidebar = sidebar
        self.pane = pane
        self.page = page
    }

    public var body: some View {
        let widths = configuration.sidebarColumn(in: width)
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar()
                #if os(iOS)
                    // The toggle sits in the rail on the right, as the Duo's apps keep it.
                    .toolbar(removing: .sidebarToggle)
                #endif
                .overlay(alignment: .trailing) { SidebarBorderLine(border: configuration.sidebarBorder) }
                // Outermost, so the system reads the widths; under the toolbar removal it drew 320.
                .navigationSplitViewColumnWidth(min: widths.min, ideal: widths.ideal, max: widths.max)
        } detail: {
            // Pages push over the pane with Back, which shows the pane as it was; the sidebar stays.
            NavigationStack(path: $path) {
                pane()
                    .toolbar { sidebarToggle }
                    #if os(iOS)
                        // With the sidebar hidden, the system would put its toggle back at the left.
                        .toolbar(removing: .sidebarToggle)
                    #endif
                    .navigationDestination(for: Page.self) { value in
                        page(value)
                            // A page in the pane keeps the toggle, so a hidden sidebar comes back.
                            .toolbar { sidebarToggle }
                    }
            }
            #if os(iOS)
                // No background behind the Duo's side rail.
                .containerBackground(.clear, for: .navigation)
                // The pane's own narrowest, or the system keeps one that stops the sidebar short.
                .navigationSplitViewColumnWidth(
                    min: Swift.max(insetWidth - widths.max, 0), ideal: Swift.max(width - widths.ideal, 0))
            #endif
        }
        .environment(\.shellLayout, .split)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: {
            insetWidth = $0
            width = Self.windowWidth(atLeast: $0)
        }
        // Pages always land in the pane. Below the host's width the sidebar steps aside until Back.
        .onChange(of: path.isEmpty) { _, closed in
            if !closed, width < configuration.pageHidesSidebarBelow, columnVisibility != .detailOnly {
                visibilityBeforePage = columnVisibility
                columnVisibility = .detailOnly
            } else if closed, let before = visibilityBeforePage {
                visibilityBeforePage = nil
                columnVisibility = before
            }
        }
    }

    /// The window's whole width, a side rail included, which the safe area leaves out of the
    /// split's own frame. The Mac has no rail, so its split's width is the window's.
    private static func windowWidth(atLeast splitWidth: CGFloat) -> CGFloat {
        #if os(iOS)
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
            return Swift.max(scene?.coordinateSpace.bounds.width ?? 0, splitWidth)
        #else
            return splitWidth
        #endif
    }

    /// Shows or hides the sidebar from the top of the rail. A Mac keeps its window toolbar's own
    /// toggle, so the rail adds none.
    @ToolbarContentBuilder
    private var sidebarToggle: some ToolbarContent {
        #if os(iOS)
            ToolbarItem(placement: .primaryAction) {
                let hidden = columnVisibility == .detailOnly
                Button(configuration.sidebarToggleTitle(hidden), systemImage: "sidebar.leading") {
                    withAnimation { columnVisibility = hidden ? .doubleColumn : .detailOnly }
                }
            }
        #else
            ToolbarItem(placement: .automatic) { EmptyView() }
        #endif
    }
}
