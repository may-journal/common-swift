import SwiftUI

/// The thin line between the sidebar and the pane, drawn on iOS, which has none of its own.
/// The Mac's split draws its own divider, so the shell adds none there.
public struct SidebarBorder: Sendable, Equatable {
    /// Whether the line shows.
    public var isVisible: Bool
    /// The line's color; nil is the system's separator color, which follows light and dark.
    public var color: Color?
    /// The line's width in points; nil is one pixel of the screen.
    public var width: CGFloat?

    public init(isVisible: Bool = true, color: Color? = nil, width: CGFloat? = nil) {
        self.isVisible = isVisible
        self.color = color
        self.width = width
    }

    /// A border that draws no line at all.
    public static let hidden = SidebarBorder(isVisible: false)

    /// The width the line draws at on a screen of `displayScale` pixels per point, or nil when
    /// no line shows.
    public func drawnWidth(displayScale: CGFloat) -> CGFloat? {
        guard isVisible else { return nil }
        return width ?? 1 / Swift.max(displayScale, 1)
    }
}

/// Draws the border on the sidebar's trailing edge, the left one in a right-to-left layout.
/// It takes no touches, so the system's drag on the column's edge still reaches the split.
struct SidebarBorderLine: View {
    let border: SidebarBorder
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        #if os(iOS)
            if let width = border.drawnWidth(displayScale: displayScale) {
                Rectangle()
                    .fill(border.color ?? Color(uiColor: .separator))
                    .frame(width: width)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        #endif
    }
}
