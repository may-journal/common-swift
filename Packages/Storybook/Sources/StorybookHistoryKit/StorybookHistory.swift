import Foundation

/// When each requirement acceptance was added and last changed, read from the host's git
/// history at build time. The catalog badges a page from the acceptance its name starts with.
public struct StorybookHistory: Codable, Equatable, Sendable {
    /// The commit the build was made from.
    public var commit: String
    /// Each acceptance's dates, by its ID, such as "0006.3".
    public var acceptances: [String: Acceptance]

    public init(commit: String, acceptances: [String: Acceptance]) {
        self.commit = commit
        self.acceptances = acceptances
    }

    /// One acceptance's history and its Then line.
    public struct Acceptance: Codable, Equatable, Sendable {
        /// When the commit that added the acceptance was made, and that commit.
        public var added: Date
        public var addedIn: String
        /// When the commit that last changed the acceptance's lines was made.
        public var changed: Date
        /// The acceptance's Then line, without "Then".
        public var then: String

        public init(added: Date, addedIn: String, changed: Date, then: String) {
            self.added = added
            self.addedIn = addedIn
            self.changed = changed
            self.then = then
        }
    }

    /// The file the build plugin writes and a host bundles.
    public static let resource = "storybook-history"

    /// The history a build bundled, or nil when the build had no git history to read.
    public static func bundled(in bundle: Bundle = .main) -> StorybookHistory? {
        guard let url = bundle.url(forResource: resource, withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else { return nil }
        return try? decoder.decode(StorybookHistory.self, from: data)
    }

    /// Reads and writes dates as ISO 8601, as git prints them.
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    /// The badge an acceptance earns: New when the build's commit added it, else when it
    /// changed, else when it was added. An ID the history lacks earns none.
    public func badge(for id: String) -> StorybookBadge? {
        guard let acceptance = acceptances[id] else { return nil }
        if acceptance.addedIn == commit { return .new }
        if acceptance.changed > acceptance.added { return .changed(acceptance.changed) }
        return .added(acceptance.added)
    }
}

/// What a page's row, card and header show about its acceptance's history.
public enum StorybookBadge: Equatable, Sendable {
    case new
    case changed(Date)
    case added(Date)
}
