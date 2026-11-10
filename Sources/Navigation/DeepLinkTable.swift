import Foundation

/// URL to route, as a table with one small parser per host rather than one long switch.
/// Each parser returns nil for a path it does not know, and the link then opens nothing.
public struct DeepLinkTable<Route>: Sendable {
    public typealias Parser = @Sendable (DeepLink) -> Route?

    /// The custom scheme the app registers in its Info.plist.
    public let scheme: String
    private let parsers: [String: Parser]

    public init(scheme: String, parsers: [String: Parser]) {
        self.scheme = scheme
        // `DeepLink` lowercases the host, so the keys must match it.
        self.parsers = Dictionary(
            parsers.map { ($0.key.lowercased(), $0.value) }, uniquingKeysWith: { first, _ in first }
        )
    }

    /// The route `url` names, or nil when it is another scheme, an unknown host or a bad path.
    public func route(from url: URL) -> Route? {
        guard let link = DeepLink(url: url, scheme: scheme) else { return nil }
        return parsers[link.host]?(link)
    }
}

/// A route that prints its own link, for share sheets, copy-link and widget taps.
public protocol Linkable {
    var deepLink: DeepLink { get }
}

extension DeepLinkTable where Route: Linkable {
    /// The URL for `route` under this table's scheme; `route(from:)` reads it back.
    public func url(for route: Route) -> URL? {
        route.deepLink.url(scheme: scheme)
    }
}
