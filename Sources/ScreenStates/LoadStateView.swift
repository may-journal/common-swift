import SwiftUI

/// Shows a spinner while loading, a failure with Try Again, the empty view, or the content.
/// Every screen that loads data runs this one switch.
public struct LoadStateView<Value, Empty: View, Content: View>: View {
    let state: LoadState<Value>
    let isEmpty: (Value) -> Bool
    let retry: (() -> Void)?
    let empty: () -> Empty
    let content: (Value) -> Content

    /// Shows `state`, and offers Try Again on a failure only when `retry` is set.
    public init(
        _ state: LoadState<Value>, isEmpty: @escaping (Value) -> Bool,
        retry: (() -> Void)? = nil, @ViewBuilder empty: @escaping () -> Empty,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.state = state
        self.isEmpty = isEmpty
        self.retry = retry
        self.empty = empty
        self.content = content
    }

    public var body: some View {
        switch state {
        case .loading:
            ProgressView()
                .accessibilityLabel("Loading")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            FailureView(message: message, retry: retry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let value) where isEmpty(value):
            empty().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let value):
            content(value)
        }
    }
}

extension LoadStateView where Value: Collection {
    /// Shows `state`, treating an empty collection as nothing loaded.
    public init(
        _ state: LoadState<Value>, retry: (() -> Void)? = nil,
        @ViewBuilder empty: @escaping () -> Empty,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.init(state, isEmpty: \.isEmpty, retry: retry, empty: empty, content: content)
    }
}
