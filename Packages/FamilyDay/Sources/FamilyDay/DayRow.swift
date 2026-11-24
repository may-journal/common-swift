/// The one row an app writes into a day. It holds the sender, a one-line title, a kicker and the
/// link that opens the sender at that day.
public struct DayRow: Hashable, Identifiable, Codable, Sendable {
    /// One line, such as "Dinner groceries".
    public let title: String
    /// A few words after the sender's name, such as "receipt" or "4 photos, 3 with words".
    public let kicker: String
    /// Opens the sender at the row's day.
    public let link: DayLink

    /// A row that opens `sender` at `day`, and at `item` when the app names one.
    public init(sender: FamilyApp, day: DayKey, title: String, kicker: String, item: String? = nil) {
        self.title = title
        self.kicker = kicker
        link = DayLink(sender, day: day, item: item)
    }

    /// The app that wrote the row, which its link opens.
    public var sender: FamilyApp { link.app }

    /// The day the row belongs to.
    public var day: DayKey { link.day }

    /// The link and the title, so two rows a sender writes without an item stay apart.
    public var id: Identity { Identity(link: link, title: title) }

    /// What tells one row from another in a day.
    public struct Identity: Hashable, Sendable {
        public let link: DayLink
        public let title: String
    }
}
