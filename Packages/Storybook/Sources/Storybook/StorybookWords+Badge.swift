import Foundation

/// The badges a page earns from its acceptance's history.
extension StorybookWords {
    public static var new: String {
        String(
            localized: "badge.new", defaultValue: "New", bundle: .module,
            comment: "Badge: the page's acceptance came in this build's commit")
    }

    /// "Changed 2 days ago", with the time since as the system words it.
    public static func changed(_ ago: String) -> String {
        String(
            localized: "badge.changed", defaultValue: "Changed \(ago)", bundle: .module,
            comment: "Caption: when the page's acceptance last changed, such as 2 days ago")
    }

    /// "Added Oct 30", with the date as the system words it.
    public static func added(_ date: String) -> String {
        String(
            localized: "badge.added", defaultValue: "Added \(date)", bundle: .module,
            comment: "Caption: the day the page's acceptance was added, such as Oct 30")
    }

    /// The badge's words: New, or how long ago it changed, or the day it was added.
    public static func badge(_ badge: StorybookBadge) -> String {
        switch badge {
        case .new: new
        case .changed(let date): changed(date.formatted(.relative(presentation: .named)))
        case .added(let date): added(date.formatted(.dateTime.month(.abbreviated).day()))
        }
    }

    /// "Added Oct 30, 2026 · Changed 2 days ago": an acceptance's dates above its page.
    public static func dates(_ acceptance: StorybookHistory.Acceptance) -> String {
        let added = added(acceptance.added.formatted(date: .abbreviated, time: .omitted))
        let changed = changed(acceptance.changed.formatted(.relative(presentation: .named)))
        return "\(added) · \(changed)"
    }
}
