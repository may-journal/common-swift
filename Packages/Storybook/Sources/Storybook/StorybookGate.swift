import Foundation

/// Who may see the Storybook catalog, injected into `StorybookAvailability`: `.debugOnly` by
/// default, or `.debugOrSandbox` from `StorybookSandbox`, the one product that links StoreKit.
public struct StorybookGate: Sendable {
    /// Whether this is a Debug build, which starts allowed and unlocked before any answer lands.
    public let isDebug: Bool
    private let answer: @Sendable () async -> Bool?

    /// A gate that starts from `isDebug` and asks `allows` once whether the build may show the
    /// catalog. A nil answer means the question failed, as when offline, and is asked again.
    public init(isDebug: Bool, allows: @escaping @Sendable () async -> Bool?) {
        self.isDebug = isDebug
        answer = allows
    }

    /// Debug builds only: every other build shows plain text where the version row is.
    public static var debugOnly: StorybookGate {
        StorybookGate(isDebug: isDebugBuild) { isDebugBuild }
    }

    /// Whether the package was compiled for Debug, which follows the app's own configuration.
    public static var isDebugBuild: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }

    func allows() async -> Bool? {
        await answer()
    }
}
