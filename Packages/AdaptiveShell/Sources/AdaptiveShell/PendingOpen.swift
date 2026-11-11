import Observation
import SwiftUI

/// A request the system asked the app to open, held until the screen that shows it appears.
/// A cold launch hears a link before the app has loaded, so the request waits here.
@Observable
@MainActor
public final class PendingOpen<Request: Equatable> {
    /// The request the app opens next.
    public var pending: Request?
    /// Reads a link into a request; nil means the link is not the app's to open.
    @ObservationIgnored private let read: (URL) -> Request?

    public init(read: @escaping (URL) -> Request?) {
        self.read = read
    }

    /// Takes a link the app reads; any other link is ignored.
    public func open(_ link: URL) {
        if let request = read(link) { pending = request }
    }
}

extension View {
    /// Hands each held request to `perform` once, on a cold launch too, and takes the links the
    /// system opens. Put it on a view that shows once the app can open a request.
    public func opensRequests<Request: Equatable>(
        _ requests: PendingOpen<Request>, perform: @escaping (Request) -> Void
    ) -> some View {
        onOpenURL { requests.open($0) }
            .onChange(of: requests.pending, initial: true) { _, request in
                guard let request else { return }
                requests.pending = nil
                perform(request)
            }
    }
}
