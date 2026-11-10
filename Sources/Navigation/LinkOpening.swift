import Foundation

/// What opening a link did.
public enum LinkOpening<Route: Hashable>: Equatable {
    /// The link named this route, and the router shows it.
    case opened(Route)
    /// The link named a route whose content is gone; show a "Not Found" sheet, not a blank screen.
    case notFound(Route)
    /// The link is not the app's to open.
    case notOurs
}

extension Router {
    /// Opens `url` through `table`: a route whose content `exists` says is gone opens nothing.
    /// The one door for `onOpenURL`, handoff and widget taps, so they all land the same way.
    @discardableResult
    public func open(
        _ url: URL,
        with table: DeepLinkTable<Route>,
        exists: (Route) -> Bool = { _ in true }
    ) -> LinkOpening<Route> {
        guard let route = table.route(from: url) else { return .notOurs }
        guard exists(route) else { return .notFound(route) }
        show(route)
        return .opened(route)
    }
}
