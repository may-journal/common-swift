import Foundation

/// What a link names.
public enum LinkOpening<Route: Hashable>: Equatable {
    /// The link names this route, whose content exists.
    case opened(Route)
    /// The link names a route whose content is gone; show "Not Found", not a blank screen.
    case notFound(Route)
    /// The link is not the app's to open.
    case notOurs
}

extension Router {
    /// Reads `url` through `table` without moving: the app decides how to go there.
    /// An editing screen sends `.opened` through its `LeaveGuard`, so a link never drops a draft.
    public func resolve(
        _ url: URL,
        with table: DeepLinkTable<Route>,
        exists: (Route) -> Bool = { _ in true }
    ) -> LinkOpening<Route> {
        guard let route = table.route(from: url) else { return .notOurs }
        return exists(route) ? .opened(route) : .notFound(route)
    }

    /// Reads `url` and shows the route it names, for a stack with no unsaved work to guard.
    @discardableResult
    public func open(
        _ url: URL,
        with table: DeepLinkTable<Route>,
        exists: (Route) -> Bool = { _ in true }
    ) -> LinkOpening<Route> {
        let opening = resolve(url, with: table, exists: exists)
        if case .opened(let route) = opening {
            show(route)
        }
        return opening
    }
}
