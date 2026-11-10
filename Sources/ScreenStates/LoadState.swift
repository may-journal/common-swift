/// Where a screen's data stands: still loading, failed with a message, or loaded.
public enum LoadState<Value> {
    case loading
    case failed(String)
    case loaded(Value)
}

extension LoadState: Equatable where Value: Equatable {}
extension LoadState: Sendable where Value: Sendable {}
