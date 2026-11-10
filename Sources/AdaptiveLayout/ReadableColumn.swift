import SwiftUI
import Theme

extension View {
    /// Centers this view in a column no wider than the theme's readable width.
    /// The side margin is the theme's narrow or wide margin, by the container's width.
    public func readableColumn(breakpoint: CGFloat = WidthClass.breakpoint) -> some View {
        modifier(ReadableColumn(breakpoint: breakpoint))
    }

    /// Draws this view on a card: the theme's surface, a hairline border and the large radius.
    public func card() -> some View {
        modifier(Card())
    }
}

private struct ReadableColumn: ViewModifier {
    let breakpoint: CGFloat
    @State private var width: CGFloat = 0
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        let wide = WidthClass(width: width, breakpoint: breakpoint) == .wide
        content
            .frame(maxWidth: theme.spacing.readableWidth)
            .padding(.horizontal, wide ? theme.spacing.wideMargin : theme.spacing.margin)
            .frame(maxWidth: .infinity)
            .onWidthChange { width = $0 }
    }
}

private struct Card: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.radii.large, style: .continuous)
        content
            .padding(theme.spacing.medium)
            .background(theme.palette.surface, in: shape)
            .overlay { shape.strokeBorder(theme.palette.line, lineWidth: 1) }
    }
}
