import Foundation

/// When the code behind each requirement acceptance last changed, read from git at build time.
/// The catalog counts each page's age to the build's commit, so a build always shows the same.
public struct StorybookHistory: Codable, Equatable, Sendable {
    /// The commit the build was made from, and when it was written.
    public var commit: String
    public var buildDate: Date
    /// Each acceptance's last change, by its ID, such as "0006.3".
    public var acceptances: [String: Acceptance]
    /// Each requirement doc's title by its number, such as "Seeing the Storybook row" for "0006".
    /// A history written before titles were bundled has none.
    public var requirements: [String: String]?

    public init(
        commit: String, buildDate: Date, acceptances: [String: Acceptance], requirements: [String: String]? = nil
    ) {
        self.commit = commit
        self.buildDate = buildDate
        self.acceptances = acceptances
        self.requirements = requirements
    }

    /// The newest mainline change to the source files an acceptance's test covers, and its
    /// Then line.
    public struct Acceptance: Codable, Equatable, Sendable {
        /// When that change was written, and its commit.
        public var changed: Date
        public var changedIn: String
        /// How many mainline commits came after it up to the build's, 0 for the build's own.
        public var commitsAgo: Int
        /// The acceptance's Then line, without "Then".
        public var then: String

        public init(changed: Date, changedIn: String, commitsAgo: Int, then: String) {
            self.changed = changed
            self.changedIn = changedIn
            self.commitsAgo = commitsAgo
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

    /// The badge an acceptance earns: New when the build's commit changed its code, else its
    /// change and age at the build. An ID the history lacks earns none.
    public func badge(for id: String) -> StorybookBadge? {
        guard let acceptance = acceptances[id] else { return nil }
        if acceptance.changedIn == commit { return .new }
        let age = max(buildDate.timeIntervalSince(acceptance.changed), 0)
        return .changed(acceptance.changed, age: .seconds(age))
    }
}

/// What a page's row, card and header show about its acceptance's history.
public enum StorybookBadge: Equatable, Sendable {
    case new
    /// The day the code changed, and how long before the build's commit that was.
    case changed(Date, age: Duration)
}
