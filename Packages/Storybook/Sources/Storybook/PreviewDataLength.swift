import SwiftUI

/// How much sample text a `#Preview` shows. The catalog's header steps it; Xcode draws the
/// short default.
public enum PreviewDataLength: String, CaseIterable, Sendable {
    case empty, short, long

    /// The sample this length picks from an empty, a short and a long one.
    public func pick<Value>(empty: Value, short: Value, long: Value) -> Value {
        switch self {
        case .empty: empty
        case .short: short
        case .long: long
        }
    }
}

extension EnvironmentValues {
    /// The sample-data length the catalog's header chose.
    @Entry public var previewDataLength: PreviewDataLength = .short
}

/// Builds a preview from the sample-data length in its environment. A new length builds it
/// afresh, so a preview with state starts over from the new sample.
public struct PreviewSample<Content: View>: View {
    private let content: (PreviewDataLength) -> Content
    @Environment(\.previewDataLength) private var length

    public init(@ViewBuilder content: @escaping (PreviewDataLength) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(length).id(length)
    }
}
