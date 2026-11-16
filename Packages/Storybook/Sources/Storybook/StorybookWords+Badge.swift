import Foundation

/// The words beside a page's ID chip, which say what its acceptance's history earns.
extension StorybookWords {
    /// "New in this build": a page whose acceptance came in the build's commit.
    public static var new: String {
        String(
            localized: "badge.new", defaultValue: "New in this build", bundle: .module,
            comment: "Caption: the page's acceptance came in this build's commit")
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

    /// "No git history": a page named by an acceptance in a build without git history.
    static var noHistory: String {
        String(
            localized: "badge.none", defaultValue: "No git history", bundle: .module,
            comment: "Caption: the build bundled no git history, so the page has no age")
    }

    /// "Now": the age beside the meter of a page that is new in this build.
    static var now: String {
        String(
            localized: "badge.now", defaultValue: "Now", bundle: .module,
            comment: "Short age beside the freshness meter: the page is new in this build")
    }

    /// "This build": the fresh end of the age scale above a page.
    static var scaleStart: String {
        String(
            localized: "scale.start", defaultValue: "This build", bundle: .module,
            comment: "Label under the fresh end of the five-week age scale above a page")
    }

    /// "5 weeks+": the old end of the age scale above a page.
    static var scaleEnd: String {
        String(
            localized: "scale.end", defaultValue: "5 weeks+", bundle: .module,
            comment: "Label under the old end of the age scale: five weeks or more ago")
    }

    /// "No git history in this build, so no age to place": above a page without history.
    static var noAge: String {
        String(
            localized: "sentence.badge.none",
            defaultValue: "No git history in this build, so no age to place", bundle: .module,
            comment: "Above a page in a build without git history, under its empty age scale")
    }

    /// The words under a page's label: new in this build, how long ago it changed, the day it
    /// was added, or no history.
    public static func badge(_ badge: StorybookBadge?) -> String {
        switch badge {
        case .new: new
        case .changed(let date): changed(date.formatted(.relative(presentation: .named)))
        case .added(let date): added(date.formatted(.dateTime.month(.abbreviated).day()))
        case nil: noHistory
        }
    }

    /// "16d": the short age beside the meter, as the system words a duration, or Now.
    static func age(_ badge: StorybookBadge, at now: Date = .now) -> String {
        guard let date = badge.date else { return Self.now }
        let seconds = max(now.timeIntervalSince(date), 0)
        return Duration.seconds(seconds).formatted(
            .units(allowed: [.days, .hours, .minutes], width: .narrow, maximumUnitCount: 1))
    }

    /// "Added Oct 30, 2026 · Changed 2 days ago": an acceptance's dates above its page.
    /// One that never changed shows only when it was added, as its row does.
    public static func dates(_ acceptance: StorybookHistory.Acceptance) -> String {
        let added = added(acceptance.added.formatted(date: .abbreviated, time: .omitted))
        guard acceptance.changed > acceptance.added else { return added }
        let changed = changed(acceptance.changed.formatted(.relative(presentation: .named)))
        return "\(added) · \(changed)"
    }
}
