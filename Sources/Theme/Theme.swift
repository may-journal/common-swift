import SwiftUI

/// An app's design tokens: its colors, type scale, spacing and radii.
/// Shared views read the theme from the environment, so they never name an app's colors.
public struct Theme: Sendable, Equatable {
    public var palette: Palette
    public var type: TypeScale
    public var spacing: Spacing
    public var radii: Radii

    public init(
        palette: Palette = .standard, type: TypeScale = .standard,
        spacing: Spacing = .standard, radii: Radii = .standard
    ) {
        self.palette = palette
        self.type = type
        self.spacing = spacing
        self.radii = radii
    }

    /// System colors and the system type scale, used until an app sets its own.
    public static let standard = Theme()
}

extension EnvironmentValues {
    /// The theme shared views draw with. It is `Theme.standard` until a root sets one.
    @Entry public var theme: Theme = .standard
}

extension View {
    /// Draws this view and everything inside it with `theme`.
    public func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
