import CoreGraphics

/// The sizes and words a host gives the shell. Every field has a default.
public struct ShellConfiguration: Sendable {
    /// The sidebar column's narrowest, ideal and widest width in a split. Where the platform
    /// offers it, the system lets a person drag the column between them.
    public var sidebarWidth: ColumnWidth
    /// Below this width a page opened from the sidebar moves it aside until Back. With 0, the
    /// default, the sidebar always stays beside the page.
    public var pageHidesSidebarBelow: CGFloat
    /// The rail button's label, given whether the sidebar is hidden now.
    public var sidebarToggleTitle: @Sendable @MainActor (_ hidden: Bool) -> String

    public init(
        sidebarWidth: ColumnWidth = ColumnWidth(min: 280, ideal: 360, max: 520),
        pageHidesSidebarBelow: CGFloat = 0,
        sidebarToggleTitle: @escaping @Sendable @MainActor (_ hidden: Bool) -> String = {
            $0 ? ShellWords.showSidebar : ShellWords.hideSidebar
        }
    ) {
        self.sidebarWidth = sidebarWidth
        self.pageHidesSidebarBelow = pageHidesSidebarBelow
        self.sidebarToggleTitle = sidebarToggleTitle
    }

    /// The width a page opened from the sidebar moves it aside below.
    @available(*, deprecated, renamed: "pageHidesSidebarBelow")
    public var sidebarFloatsBelow: CGFloat {
        get { pageHidesSidebarBelow }
        set { pageHidesSidebarBelow = newValue }
    }
}

/// A split column's narrowest, ideal and widest width, in points.
public struct ColumnWidth: Sendable, Equatable {
    public var min: CGFloat
    public var ideal: CGFloat
    public var max: CGFloat

    public init(min: CGFloat, ideal: CGFloat, max: CGFloat) {
        self.min = min
        self.ideal = ideal
        self.max = max
    }
}
