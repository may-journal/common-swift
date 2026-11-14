import CoreGraphics

/// The sizes and words a host gives the shell. Every field has a default.
public struct ShellConfiguration: Sendable {
    /// The sidebar column's narrowest and ideal width in a split, and an absolute cap on its
    /// widest. Where the platform offers it, the system lets a person drag the column between.
    public var sidebarWidth: ColumnWidth
    /// The share of the split's width the sidebar may be dragged to, under `sidebarWidth.max`.
    public var sidebarMaxFraction: CGFloat
    /// The thin line between the sidebar and the pane: shown, in the system's separator color,
    /// one pixel wide unless the app changes it.
    public var sidebarBorder: SidebarBorder
    /// Below this width a page opened from the sidebar moves it aside until Back. With 0, the
    /// default, the sidebar always stays beside the page.
    public var pageHidesSidebarBelow: CGFloat
    /// The rail button's label, given whether the sidebar is hidden now.
    public var sidebarToggleTitle: @Sendable @MainActor (_ hidden: Bool) -> String

    public init(
        sidebarWidth: ColumnWidth = ColumnWidth(min: 280, ideal: 360, max: .infinity),
        sidebarMaxFraction: CGFloat = 0.5,
        sidebarBorder: SidebarBorder = SidebarBorder(),
        pageHidesSidebarBelow: CGFloat = 0,
        sidebarToggleTitle: @escaping @Sendable @MainActor (_ hidden: Bool) -> String = {
            $0 ? ShellWords.showSidebar : ShellWords.hideSidebar
        }
    ) {
        self.sidebarWidth = sidebarWidth
        self.sidebarMaxFraction = sidebarMaxFraction
        self.sidebarBorder = sidebarBorder
        self.pageHidesSidebarBelow = pageHidesSidebarBelow
        self.sidebarToggleTitle = sidebarToggleTitle
    }

    /// The width a page opened from the sidebar moves it aside below.
    @available(*, deprecated, renamed: "pageHidesSidebarBelow")
    public var sidebarFloatsBelow: CGFloat {
        get { pageHidesSidebarBelow }
        set { pageHidesSidebarBelow = newValue }
    }

    /// The widths the shell hands the system in a split `splitWidth` points wide, or the ideal
    /// as the widest before it is measured. Neither the narrowest nor the ideal passes the widest.
    public func sidebarColumn(in splitWidth: CGFloat) -> ColumnWidth {
        let share = splitWidth > 0 ? splitWidth * sidebarMaxFraction : sidebarWidth.ideal
        let widest = Swift.min(sidebarWidth.max, share)
        return ColumnWidth(
            min: Swift.min(sidebarWidth.min, widest), ideal: Swift.min(sidebarWidth.ideal, widest),
            max: widest)
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
