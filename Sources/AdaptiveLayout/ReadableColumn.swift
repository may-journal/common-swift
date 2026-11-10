import SwiftUI
import Theme

extension View {
    /// Places this view, leading-aligned, in a centered column no wider than the readable width.
    /// The side margin is the theme's narrow or wide margin, by the container's width.
    public func readableColumn(breakpoint: CGFloat = WidthClass.breakpoint) -> some View {
        modifier(ReadableColumn(breakpoint: breakpoint))
    }
}

private struct ReadableColumn: ViewModifier {
    let breakpoint: CGFloat
    @State private var widthClass = WidthClass.narrow
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        let wide = widthClass == .wide
        content
            .frame(maxWidth: theme.spacing.readableWidth, alignment: .leading)
            .padding(.horizontal, wide ? theme.spacing.wideMargin : theme.spacing.margin)
            .frame(maxWidth: .infinity)
            .onWidthClassChange(breakpoint: breakpoint) { widthClass = $0 }
    }
}
