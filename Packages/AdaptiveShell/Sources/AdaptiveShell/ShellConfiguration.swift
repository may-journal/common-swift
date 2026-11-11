import CoreGraphics

/// The sizes and words a host gives the shell. Every field has a default.
public struct ShellConfiguration: Sendable {
    /// The sidebar column's narrowest, ideal and widest width in a split.
    public var sidebarWidth: ColumnWidth
    /// Below this width a split floats the sidebar over the pane, so an open page moves it aside.
    public var sidebarFloatsBelow: CGFloat
    /// The rail button's label, given whether the sidebar is hidden now.
    public var sidebarToggleTitle: @Sendable @MainActor (_ hidden: Bool) -> String

    public init(
        sidebarWidth: ColumnWidth = ColumnWidth(min: 280, ideal: 360, max: 520),
        sidebarFloatsBelow: CGFloat = 800,
        sidebarToggleTitle: @escaping @Sendable @MainActor (_ hidden: Bool) -> String = {
            $0 ? ShellWords.showSidebar : ShellWords.hideSidebar
        }
    ) {
        self.sidebarWidth = sidebarWidth
        self.sidebarFloatsBelow = sidebarFloatsBelow
        self.sidebarToggleTitle = sidebarToggleTitle
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
