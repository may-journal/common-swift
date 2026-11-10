import Observation

/// Holds a request heard before the screen can act, such as a widget tap on a cold launch.
/// The screen takes it once its data loads.
@Observable
@MainActor
public final class PendingOpen<Request: Equatable> {
    /// The request waiting to be taken. A newer request replaces an older one.
    public private(set) var pending: Request?

    public init() {}

    /// Keeps `request` until `take()`.
    public func hold(_ request: Request) {
        pending = request
    }

    /// Hands over the waiting request once, then forgets it.
    public func take() -> Request? {
        defer { pending = nil }
        return pending
    }
}
