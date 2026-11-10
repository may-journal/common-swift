import Observation

/// Owns one stack's path of routes, so the path survives however the views inside redraw.
/// A `NavigationStack(path:)` binds to `path`; screens ask the router to move, never the view.
@Observable
@MainActor
public final class Router<Route: Hashable> {
    /// The screens pushed over the root, oldest first.
    public var path: [Route]

    public init(path: [Route] = []) {
        self.path = path
    }

    /// The screen on top, or nil at the root.
    public var top: Route? { path.last }

    /// Pushes `route`, even when it is already open further down.
    public func push(_ route: Route) {
        path.append(route)
    }

    /// Brings `route` to the front, never twice: it pops back to an open copy, else pushes it.
    public func show(_ route: Route) {
        guard top != route else { return }
        if let open = path.lastIndex(of: route) {
            path.removeSubrange(path.index(after: open)...)
        } else {
            path.append(route)
        }
    }

    /// Pops the top screen. Returns false at the root.
    @discardableResult
    public func pop() -> Bool {
        guard !path.isEmpty else { return false }
        path.removeLast()
        return true
    }

    /// Pops every screen and shows the root.
    public func popToRoot() {
        path.removeAll()
    }

    /// Replaces the whole path, as a deep link that names a nested screen does.
    public func reset(to routes: [Route]) {
        path = routes
    }
}
