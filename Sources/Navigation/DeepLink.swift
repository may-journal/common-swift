import Foundation

/// A custom-scheme link taken apart: `scheme://host/a/b?key=value` is host, path and query.
/// Routes parse from it and print to it, so incoming links and share links stay one format.
public struct DeepLink: Equatable, Sendable {
    /// Lowercased, since URL hosts ignore case.
    public var host: String
    /// Each segment decoded, so a segment may hold a slash.
    public var path: [String]
    /// The first value for each key; a key with no value reads as "".
    public var query: [String: String]

    public init(host: String, path: [String] = [], query: [String: String] = [:]) {
        self.host = host.lowercased()
        self.path = path
        self.query = query
    }

    /// The link `url` carries under `scheme`, or nil for any other scheme or a link with no host.
    public init?(url: URL, scheme: String) {
        guard
            let parts = URLComponents(url: url, resolvingAgainstBaseURL: false),
            parts.scheme?.lowercased() == scheme.lowercased(),
            let host = parts.host, !host.isEmpty
        else { return nil }
        self.host = host.lowercased()
        path = parts.percentEncodedPath.split(separator: "/").map { segment in
            segment.removingPercentEncoding ?? String(segment)
        }
        var query: [String: String] = [:]
        for item in parts.queryItems ?? [] where query[item.name] == nil {
            query[item.name] = item.value ?? ""
        }
        self.query = query
    }

    /// The URL for this link under `scheme`, with query keys sorted so equal links print alike.
    public func url(scheme: String) -> URL? {
        var parts = URLComponents()
        parts.scheme = scheme
        parts.host = host
        if !path.isEmpty {
            parts.percentEncodedPath = "/" + path.map(Self.encode).joined(separator: "/")
        }
        if !query.isEmpty {
            parts.queryItems = query.keys.sorted().map { URLQueryItem(name: $0, value: query[$0]) }
        }
        return parts.url
    }

    /// Characters a path segment keeps as they are: a path's, less the slash between segments.
    private static let segmentAllowed = CharacterSet.urlPathAllowed.subtracting(["/"])

    private static func encode(_ segment: String) -> String {
        segment.addingPercentEncoding(withAllowedCharacters: segmentAllowed) ?? segment
    }
}
