import SwiftUI

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension Color {
    /// A color from a 24-bit `0xRRGGBB` value in sRGB.
    public init(rgb: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB, red: Self.channel(rgb, 16), green: Self.channel(rgb, 8),
            blue: Self.channel(rgb, 0), opacity: opacity)
    }

    /// A color that draws `light` in light appearance and `dark` in dark appearance.
    public init(light: UInt32, dark: UInt32, lightOpacity: Double = 1, darkOpacity: Double = 1) {
        let light = PlatformColor.make(light, opacity: lightOpacity)
        let dark = PlatformColor.make(dark, opacity: darkOpacity)
        #if canImport(UIKit)
        self.init(uiColor: UIColor { $0.userInterfaceStyle == .dark ? dark : light })
        #else
        self.init(
            nsColor: NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
            })
        #endif
    }

    /// A color stored as `#RRGGBB`, or nil when the text is not exactly that.
    public init?(hex: String) {
        guard hex.count == 7, hex.hasPrefix("#"),
            hex.dropFirst().allSatisfy(\.isHexDigit),
            let value = UInt32(hex.dropFirst(), radix: 16)
        else { return nil }
        self.init(rgb: value)
    }

    fileprivate static func channel(_ rgb: UInt32, _ shift: UInt32) -> Double {
        Double((rgb >> shift) & 0xFF) / 255
    }
}

#if canImport(UIKit)
private typealias PlatformColor = UIColor
#else
private typealias PlatformColor = NSColor
#endif

extension PlatformColor {
    fileprivate static func make(_ rgb: UInt32, opacity: Double) -> PlatformColor {
        PlatformColor(
            red: Color.channel(rgb, 16), green: Color.channel(rgb, 8),
            blue: Color.channel(rgb, 0), alpha: opacity)
    }
}
