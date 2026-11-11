import Storybook
import StoreKit

extension StorybookGate {
    /// Debug, or the App Store's sandbox: TestFlight and App Review. The App Store ships the
    /// TestFlight archive itself, so only its own answer tells them apart.
    public static var debugOrSandbox: StorybookGate {
        debugOrSandbox(isDebug: isDebugBuild) {
            try await AppTransaction.shared.payloadValue.environment
        }
    }

    /// The sandbox rule over any source of the App Store's answer, so a test can replay one.
    /// A source that throws, as for a build the App Store never signed, is asked again later.
    public static func debugOrSandbox(
        isDebug: Bool,
        environment: @escaping @Sendable () async throws -> AppStore.Environment
    ) -> StorybookGate {
        StorybookGate(isDebug: isDebug) {
            guard let answer = try? await environment() else { return nil }
            return isDebug || answer == .sandbox
        }
    }
}
