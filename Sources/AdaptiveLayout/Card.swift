import SwiftUI
import Theme

extension View {
    /// Draws this view on a card: the theme's surface, a one-pixel border and the large radius.
    public func card() -> some View {
        modifier(Card())
    }
}

private struct Card: ViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.displayScale) private var displayScale

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.radii.large, style: .continuous)
        content
            .padding(theme.spacing.medium)
            .background(theme.palette.surface, in: shape)
            .overlay { shape.strokeBorder(theme.palette.line, lineWidth: 1 / displayScale) }
    }
}
