import Foundation

/// The package's own words, as entries of its String Catalog. A host overrides the Settings
/// words through `StorybookLabels`; the catalog's own labels always come from here.
public enum StorybookWords {
    /// "Storybook": the catalog's title and the Settings row that opens it.
    public static var name: String {
        String(
            localized: "name.storybook", defaultValue: "Storybook", bundle: .module,
            comment: "Name: the Debug and TestFlight catalog of every preview, as its title")
    }

    /// "Version": the Settings row that shows the app's version.
    public static var version: String {
        String(
            localized: "noun.version", defaultValue: "Version", bundle: .module,
            comment: "Noun: the Settings row that shows the app's version and build")
    }

    /// "For developers and testers only.": the footer under the Settings row to the catalog.
    public static var footer: String {
        String(
            localized: "sentence.settings.storybook",
            defaultValue: "For developers and testers only.", bundle: .module,
            comment: "Settings footer under the row that opens the Storybook catalog")
    }

    /// "Done": closes the catalog.
    static var done: String {
        String(
            localized: "verb.done", defaultValue: "Done", bundle: .module,
            comment: "Verb: the button that closes the Storybook catalog")
    }

    /// "Search": the sidebar's search prompt.
    static var search: String {
        String(
            localized: "verb.search", defaultValue: "Search", bundle: .module,
            comment: "Verb: the prompt in the Storybook sidebar's search field")
    }

    /// "Pages": the page picker's VoiceOver name.
    static var pages: String {
        String(
            localized: "noun.pages", defaultValue: "Pages", bundle: .module,
            comment: "Noun: a component's preview pages in the Storybook catalog")
    }

    /// "All Pages": the sidebar row that shows a component's pages side by side.
    static var allPages: String {
        String(
            localized: "name.allPages", defaultValue: "All Pages", bundle: .module,
            comment: "Name: the Storybook sidebar row that shows every page of a component")
    }

    /// "4 Pages": how many pages a component's grid holds.
    static func pageCount(_ count: Int) -> String {
        String(
            localized: "count.pages", defaultValue: "\(count) Pages", bundle: .module,
            comment: "Count: preview pages under a component's name in the Storybook grid")
    }

    /// "Previous": the button to the page before.
    static var previous: String {
        String(
            localized: "verb.previous", defaultValue: "Previous", bundle: .module,
            comment: "Verb: the Storybook button that opens the page before this one")
    }

    /// "Next": the button to the page after.
    static var next: String {
        String(
            localized: "verb.next", defaultValue: "Next", bundle: .module,
            comment: "Verb: the Storybook button that opens the page after this one")
    }
}
