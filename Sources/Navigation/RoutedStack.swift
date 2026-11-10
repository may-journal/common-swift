import SwiftUI

/// A navigation stack bound to a router's path, with one destination for every route.
/// It declares the destination at the root, so a redraw inside never drops a pushed screen.
public struct RoutedStack<Route: Hashable, Root: View, Destination: View>: View {
    @Bindable private var router: Router<Route>
    private let root: () -> Root
    private let destination: (Route) -> Destination

    public init(
        router: Router<Route>,
        @ViewBuilder root: @escaping () -> Root,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self.router = router
        self.root = root
        self.destination = destination
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .navigationDestination(for: Route.self, destination: destination)
        }
    }
}
