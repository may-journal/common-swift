import SwiftUI

/// The color roles shared views draw with. Each role is one color that follows the appearance.
public struct Palette: Sendable, Equatable {
    /// The screen behind everything.
    public var background: Color
    /// A card or row, which must differ from `background` in dark mode.
    public var surface: Color
    /// A well or tile set into a surface.
    public var sunken: Color
    /// The color of primary text.
    public var ink: Color
    /// The color of secondary text.
    public var mutedInk: Color
    /// The color of placeholders and timestamps.
    public var faintInk: Color
    /// The color of hairlines and borders.
    public var line: Color
    /// The brand color for actions.
    public var accent: Color
    /// Text and symbols drawn on `accent`.
    public var onAccent: Color
    /// The color of failures and destructive actions.
    public var danger: Color

    public init(
        background: Color, surface: Color, sunken: Color, ink: Color, mutedInk: Color,
        faintInk: Color, line: Color, accent: Color, onAccent: Color, danger: Color
    ) {
        self.background = background
        self.surface = surface
        self.sunken = sunken
        self.ink = ink
        self.mutedInk = mutedInk
        self.faintInk = faintInk
        self.line = line
        self.accent = accent
        self.onAccent = onAccent
        self.danger = danger
    }

    /// The system's own semantic colors, on iOS and the Mac.
    public static let standard = Palette(
        background: SystemColor.background, surface: SystemColor.surface,
        sunken: SystemColor.sunken, ink: .primary, mutedInk: .secondary,
        faintInk: SystemColor.faint, line: SystemColor.line, accent: .accentColor,
        onAccent: .white, danger: .red)
}

/// The platform's semantic colors behind `Palette.standard`.
private enum SystemColor {
    #if canImport(UIKit)
    static let background = Color(uiColor: .systemBackground)
    static let surface = Color(uiColor: .secondarySystemBackground)
    static let sunken = Color(uiColor: .tertiarySystemBackground)
    static let faint = Color(uiColor: .tertiaryLabel)
    static let line = Color(uiColor: .separator)
    #else
    static let background = Color(nsColor: .windowBackgroundColor)
    static let surface = Color(nsColor: .controlBackgroundColor)
    static let sunken = Color(nsColor: .underPageBackgroundColor)
    static let faint = Color(nsColor: .tertiaryLabelColor)
    static let line = Color(nsColor: .separatorColor)
    #endif
}
