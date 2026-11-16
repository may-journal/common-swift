import Foundation

/// The words beside a page's ID chip, which say what its acceptance's history earns. Every age
/// is counted to the build's commit, never to today, so one build always words it the same.
extension StorybookWords {
    /// "New in this build": a page whose covered code changed in the build's commit.
    public static var new: String {
        String(
            localized: "badge.new", defaultValue: "New in this build", bundle: .module,
            comment: "Caption: the page's covered code changed in this build's commit")
    }

    /// "Changed Oct 30", with the day as the system words it.
    public static func changed(_ day: String) -> String {
        String(
            localized: "badge.changed", defaultValue: "Changed \(day)", bundle: .module,
            comment: "Caption: the day the page's covered code last changed, such as Oct 30")
    }

    /// "Changed Oct 30, 2026": the day above a page, with its year.
    public static func changedOn(_ date: Date) -> String {
        changed(date.formatted(date: .abbreviated, time: .omitted))
    }

    /// "3 commits ago": how many mainline commits the build's came after the code's last change.
    public static func commitsAgo(_ count: Int) -> String {
        String(
            localized: "badge.commits", defaultValue: "\(count) commits ago", bundle: .module,
            comment: "Above a page: how many commits before the build's its covered code last changed")
    }

    /// "2 days before the build": the short age beside the meter, as VoiceOver reads it.
    static func beforeBuild(_ age: String) -> String {
        String(
            localized: "badge.age", defaultValue: "\(age) before the build", bundle: .module,
            comment: "Spoken age beside the freshness meter, such as 2 days before the build")
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
            comment: "Label under the old end of the age scale: five weeks or more before the build")
    }

    /// "No git history in this build, so no age to place": above a page without history.
    static var noAge: String {
        String(
            localized: "sentence.badge.none",
            defaultValue: "No git history in this build, so no age to place", bundle: .module,
            comment: "Above a page in a build without git history, under its empty age scale")
    }

    /// The words under a page's label: new in this build, the day its code changed, or no history.
    public static func badge(_ badge: StorybookBadge?) -> String {
        switch badge {
        case .new: new
        case .changed(let date, _): changed(date.formatted(.dateTime.month(.abbreviated).day()))
        case nil: noHistory
        }
    }

    /// "16d": the short age beside the meter, in whole days, hours or minutes before the build,
    /// or Now.
    static func age(_ badge: StorybookBadge) -> String {
        guard case .changed(_, let age) = badge else { return now }
        return age.formatted(units(.narrow))
    }

    /// "16 days before the build": the short age as VoiceOver reads it; none when it is new.
    static func spokenAge(_ badge: StorybookBadge) -> String? {
        guard case .changed(_, let age) = badge else { return nil }
        return beforeBuild(age.formatted(units(.wide)))
    }

    /// The largest whole unit of an age, rounded down, so 2 days and 20 hours reads 2d.
    private static func units(_ width: Duration.UnitsFormatStyle.UnitWidth) -> Duration.UnitsFormatStyle {
        .units(
            allowed: [.days, .hours, .minutes], width: width, maximumUnitCount: 1,
            fractionalPart: .hide(rounded: .down))
    }
}
