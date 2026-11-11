import Foundation
import SwiftUI

/// The device a preview draws for: Auto uses this screen, and any other draws a frame of that
/// device's points and size classes. The header button steps Auto, iPhone, iPhone Duo, iPad
/// and Mac; a long press or a right click picks one from a menu.
public enum StorybookDevice: String, StorybookSetting {
    case auto, iphone, duo, ipad, mac

    public static let storageKey = "storybook.device"
    public static let argument = "--storybook-device"

    /// Each device's screen in points, in its usual orientation. The one table of sizes.
    private var size: CGSize? {
        switch self {
        case .auto: nil
        // iPhone 17: 402 x 874 pt.
        case .iphone: CGSize(width: 402, height: 874)
        // The owner's iPhone Duo (iPhone19,4, V68AP), open: its inner display is 2007 x 2853 px
        // at 3x, as `xcrun devicectl device info displays` reports it.
        case .duo: CGSize(width: 669, height: 951)
        // iPad Pro 11-inch (M5): 834 x 1210 pt.
        case .ipad: CGSize(width: 834, height: 1210)
        // A Mac window the size of a 1440 x 900 pt display.
        case .mac: CGSize(width: 1440, height: 900)
        }
    }

    /// How the device is usually held: a Mac's screen is wide, the others are tall.
    public var defaultOrientation: StorybookOrientation {
        self == .mac ? .landscape : .portrait
    }

    /// The frame's size in `orientation`: landscape puts the longer side across.
    public func canvasSize(_ orientation: StorybookOrientation) -> CGSize? {
        guard let size else { return nil }
        let long = max(size.width, size.height)
        let short = min(size.width, size.height)
        return orientation == .landscape
            ? CGSize(width: long, height: short) : CGSize(width: short, height: long)
    }

    /// Phones are compact across; iPad and Mac are regular. Auto keeps the screen's own.
    public var horizontalSizeClass: UserInterfaceSizeClass? {
        switch self {
        case .auto: nil
        case .iphone, .duo: .compact
        case .ipad, .mac: .regular
        }
    }

    /// A phone on its side is compact top to bottom; everything else is regular.
    public func verticalSizeClass(_ orientation: StorybookOrientation) -> UserInterfaceSizeClass? {
        switch self {
        case .auto: nil
        case .iphone, .duo: orientation == .landscape ? .compact : .regular
        case .ipad, .mac: .regular
        }
    }

    public var name: String {
        switch self {
        case .auto: StorybookWords.auto
        case .iphone: StorybookWords.iPhone
        case .duo: StorybookWords.iPhoneDuo
        case .ipad: StorybookWords.iPad
        case .mac: StorybookWords.mac
        }
    }

    /// The frame's name and size, such as "iPhone Duo 669x951".
    public func label(_ orientation: StorybookOrientation) -> String {
        guard let canvas = canvasSize(orientation) else { return name }
        return "\(name) \(Int(canvas.width))x\(Int(canvas.height))"
    }

    var symbol: String {
        switch self {
        case .auto: "rectangle.dashed"
        case .iphone: "iphone"
        case .duo: "rectangle.portrait.split.2x1"
        case .ipad: "ipad"
        case .mac: "laptopcomputer"
        }
    }
}

/// The way the device frame is held: choosing a device puts it in its usual orientation, and
/// the rotate button turns it.
public enum StorybookOrientation: String, StorybookSetting {
    case portrait, landscape

    public static let storageKey = "storybook.orientation"
    public static let argument = "--storybook-orientation"

    public var name: String {
        switch self {
        case .portrait: StorybookWords.portrait
        case .landscape: StorybookWords.landscape
        }
    }
}

/// How preview cards fill a width: as many columns as fit cards of at least
/// `minimumCellWidth`, with `gap` around and between. The grid and a single page both
/// take their widths from here.
enum StorybookLayout {
    static let gap: CGFloat = 16
    static let minimumCellWidth: CGFloat = 240

    static func columns(in width: CGFloat) -> Int {
        max(1, Int((width - gap) / (minimumCellWidth + gap)))
    }

    static func cellWidth(in width: CGFloat) -> CGFloat {
        let columns = CGFloat(columns(in: width))
        return max(0, (width - gap * (columns + 1)) / columns)
    }
}

extension View {
    /// The device's size classes. The Mac has no size classes to set, so it draws as it is.
    @ViewBuilder func storybookSizeClasses(
        device: StorybookDevice, orientation: StorybookOrientation
    ) -> some View {
        #if os(iOS)
            modifier(StorybookSizeClasses(device: device, orientation: orientation))
        #else
            self
        #endif
    }
}

#if os(iOS)
    private struct StorybookSizeClasses: ViewModifier {
        let device: StorybookDevice
        let orientation: StorybookOrientation
        @Environment(\.horizontalSizeClass) private var horizontal
        @Environment(\.verticalSizeClass) private var vertical

        func body(content: Content) -> some View {
            content
                .environment(\.horizontalSizeClass, device.horizontalSizeClass ?? horizontal)
                .environment(
                    \.verticalSizeClass, device.verticalSizeClass(orientation) ?? vertical)
        }
    }
#endif
