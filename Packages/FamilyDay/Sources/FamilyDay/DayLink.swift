import AdaptiveShell
import Foundation

/// A link that opens one app at one day, and at one thing it holds that day when `item` is set.
/// It reads `<scheme>://day/2026-12-12`, or `<scheme>://day/2026-12-12?item=<item>`.
public struct DayLink: Hashable, Codable, Sendable {
    /// The app the link opens.
    public let app: FamilyApp
    /// The day it opens at.
    public let day: DayKey
    /// The app's own identifier of what it holds that day, such as an event or a receipt.
    public let item: String?

    public init(_ app: FamilyApp, day: DayKey, item: String? = nil) {
        self.app = app
        self.day = day
        self.item = item
    }

    /// Reads a link to `app`; nil for another app's link, or one that names no day.
    public init?(_ link: URL, for app: FamilyApp) {
        // A scheme matches in any case, as the system routes it.
        guard link.scheme?.lowercased() == app.scheme, link.host() == Self.host,
            link.pathComponents.count == 2,
            let components = URLComponents(url: link, resolvingAgainstBaseURL: false),
            let day = DayKey(link.lastPathComponent)
        else { return nil }
        self.init(app, day: day, item: components.queryItems?.first { $0.name == Self.itemName }?.value)
    }

    /// The link the system hands to the app that answers its scheme.
    public var url: URL {
        var components = URLComponents()
        components.scheme = app.scheme
        components.host = Self.host
        components.path = "/\(day)"
        if let item { components.queryItems = [URLQueryItem(name: Self.itemName, value: item)] }
        // Every part is set above, so the components always make a URL.
        return components.url ?? URL(filePath: "/")
    }

    private static let host = "day"
    private static let itemName = "item"
}

extension PendingOpen where Request == DayLink {
    /// Holds the day links `app` answers, so a row or a chip tapped in a sibling opens here, even
    /// on a cold launch. Hand it to `opensRequests(_:perform:)` on the window's root view.
    public convenience init(app: FamilyApp) {
        self.init(read: { DayLink($0, for: app) })
    }
}
