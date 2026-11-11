import Foundation
import SwiftUI

/// Reads `<flag> <value>` from the launch arguments, the one parse every Storybook flag shares.
public enum StorybookLaunchArgument {
    /// The lowercased value after `flag`, or nil when the launch does not name one.
    public static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1)
        else { return nil }
        return arguments[index + 1].lowercased()
    }
}

/// A choice the catalog's header buttons make for every preview. Each persists in user
/// defaults and takes `<argument> <raw value>` at launch, so `devicectl` and `simctl`
/// launches show a preview repeatably.
public protocol StorybookSetting: RawRepresentable<String>, CaseIterable, Hashable
where AllCases == [Self] {
    static var storageKey: String { get }
    static var argument: String { get }
    var name: String { get }
}

extension StorybookSetting {
    /// Saves and returns the value a launch argument names, holding until the header button
    /// changes it, or returns nil when none is named.
    @discardableResult public static func applyLaunchArgument(
        _ arguments: [String], to defaults: UserDefaults
    ) -> Self? {
        guard let raw = StorybookLaunchArgument.value(after: argument, in: arguments),
            let value = Self(rawValue: raw)
        else { return nil }
        defaults.set(value.rawValue, forKey: storageKey)
        return value
    }

    /// The next value in order, back to the first after the last: one tap per step.
    public var next: Self {
        let all = Self.allCases
        let index = all.firstIndex(of: self) ?? all.startIndex
        return all[(index + 1) % all.count]
    }
}

/// Every setting's launch argument, applied in one place.
enum StorybookSettings {
    static func apply(_ arguments: [String], to defaults: UserDefaults) {
        // A device named at launch starts in its usual orientation unless the launch names one.
        if let device = StorybookDevice.applyLaunchArgument(arguments, to: defaults) {
            defaults.set(
                device.defaultOrientation.rawValue, forKey: StorybookOrientation.storageKey)
        }
        StorybookOrientation.applyLaunchArgument(arguments, to: defaults)
        StorybookTextSize.applyLaunchArgument(arguments, to: defaults)
        PreviewDataLength.applyLaunchArgument(arguments, to: defaults)
    }
}

/// The Dynamic Type size the previews draw at. Default leaves the device's own setting.
public enum StorybookTextSize: String, StorybookSetting {
    case `default`, large, largest

    public static let storageKey = "storybook.textSize"
    public static let argument = "--storybook-text-size"

    public var dynamicTypeSize: DynamicTypeSize? {
        switch self {
        case .default: nil
        case .large: .xxxLarge
        case .largest: .accessibility5
        }
    }

    public var name: String {
        switch self {
        case .default: StorybookWords.defaultText
        case .large: StorybookWords.largeText
        case .largest: StorybookWords.largestText
        }
    }
}

extension PreviewDataLength: StorybookSetting {
    public static let storageKey = "storybook.dataLength"
    public static let argument = "--storybook-data-length"

    public var name: String {
        switch self {
        case .empty: StorybookWords.emptyData
        case .short: StorybookWords.shortData
        case .long: StorybookWords.longData
        }
    }
}

extension View {
    /// Draws a preview at the header's text size and sample-data length, with the size classes
    /// of the header's device.
    func storybookPreviewSettings() -> some View {
        modifier(StorybookPreviewSettings())
    }
}

private struct StorybookPreviewSettings: ViewModifier {
    @AppStorage(StorybookTextSize.storageKey) private var textSize: StorybookTextSize = .default
    @AppStorage(PreviewDataLength.storageKey) private var dataLength: PreviewDataLength = .short
    @AppStorage(StorybookDevice.storageKey) private var device: StorybookDevice = .auto
    @AppStorage(StorybookOrientation.storageKey)
    private var orientation: StorybookOrientation = .portrait

    @Environment(\.dynamicTypeSize) private var deviceSize

    func body(content: Content) -> some View {
        content
            .dynamicTypeSize(textSize.dynamicTypeSize ?? deviceSize)
            .environment(\.previewDataLength, dataLength)
            .storybookSizeClasses(device: device, orientation: orientation)
    }
}
