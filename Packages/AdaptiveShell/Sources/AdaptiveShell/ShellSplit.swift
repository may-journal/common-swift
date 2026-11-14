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
    /// The window's width, which says whether an opened page moves the sidebar aside.
    @State private var width: CGFloat = 0
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
        let widths = configuration.sidebarWidth
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar()
                .navigationSplitViewColumnWidth(min: widths.min, ideal: widths.ideal, max: widths.max)
                #if os(iOS)
                    // The toggle sits in the rail on the right, as the Duo's apps keep it.
                    .toolbar(removing: .sidebarToggle)
                #endif
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
            #endif
        }
        .environment(\.shellLayout, .split)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGFloat.self) {
            $0.size.width
        } action: {
            width = $0
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
