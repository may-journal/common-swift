import SwiftUI
import Testing
import Theme
import UITestingLibrary

/// Runs every screen test one at a time, since rendering a screen closes the one before.
@MainActor
@Suite(.serialized) struct ThemeTests {}

/// A shared view as a package would write it: it reads the theme and names no app colors.
struct Badge: View {
    let name: String
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.small) {
            Swatch(name: "\(name) accent", color: theme.palette.accent)
            Text("\(name) gap \(Int(theme.spacing.medium))")
            Text("\(name) corner \(Int(theme.radii.large))")
            Text("\(name) body \(Int(theme.type.body.size))").font(theme.type.body)
        }
    }
}

/// Prints the color it draws as `#RRGGBB`, so a test reads what the screen resolved.
struct Swatch: View {
    let name: String
    let color: Color
    @Environment(\.self) private var environment

    var body: some View {
        Text("\(name) \(Swatch.hex(color.resolve(in: environment)))")
            .foregroundStyle(color)
    }

    static func hex(_ color: Color.Resolved) -> String {
        let parts = [color.red, color.green, color.blue].map { channel in
            String(format: "%02X", Int((min(max(channel, 0), 1) * 255).rounded()))
        }
        return "#" + parts.joined()
    }
}

/// An app's own tokens, as may-photos would hand them in.
enum Brand {
    static let indigo = Color(light: 0x4F_46_E5, dark: 0x8B_85_F5)

    static let theme = Theme(
        palette: palette(accent: indigo),
        spacing: Spacing(medium: 14), radii: Radii(large: 28))

    static func palette(accent: Color) -> Palette {
        var palette = Palette.standard
        palette.accent = accent
        return palette
    }
}
