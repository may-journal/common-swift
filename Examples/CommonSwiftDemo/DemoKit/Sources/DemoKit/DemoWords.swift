import Foundation

/// The demo's words, as entries of its String Catalog.
enum DemoWords {
    static var packages: String {
        String(
            localized: "noun.packages", defaultValue: "Packages", bundle: .module,
            comment: "Noun: the title of the demo's list of common-swift packages")
    }

    static var settings: String {
        String(
            localized: "noun.settings", defaultValue: "Settings", bundle: .module,
            comment: "Noun: the demo's Settings page, which holds the Storybook row")
    }

    static var openAgain: String {
        String(
            localized: "action.openAgain", defaultValue: "Open Again", bundle: .module,
            comment: "Action: opens the picked package at work again, after it was closed")
    }

    static var about: String {
        String(
            localized: "noun.about", defaultValue: "About", bundle: .module,
            comment: "Noun: the sample diary's page that says what AdaptiveShell gives an app")
    }

    static var done: String {
        String(
            localized: "verb.done", defaultValue: "Done", bundle: .module,
            comment: "Verb: closes the sample diary and returns to the list of packages")
    }

    static var diary: String {
        String(
            localized: "noun.diary", defaultValue: "Diary", bundle: .module,
            comment: "Noun: the title of the sample diary drawn by AdaptiveShell")
    }

    static var pickEntry: String {
        String(
            localized: "sentence.pickEntry", defaultValue: "Pick an entry.", bundle: .module,
            comment: "The sample diary's pane prompt while no entry is picked")
    }

    static var kites: String {
        String(
            localized: "sample.kites", defaultValue: "Kites over the dunes", bundle: .module,
            comment: "A sample diary entry's title")
    }

    static var dunes: String {
        String(
            localized: "sample.dunes", defaultValue: "A walk on the dunes", bundle: .module,
            comment: "A sample diary entry's title")
    }

    static var tea: String {
        String(
            localized: "sample.tea", defaultValue: "Tea after the walk", bundle: .module,
            comment: "A sample diary entry's title")
    }

    static var prompt: String {
        String(
            localized: "sentence.prompt", defaultValue: "Pick a package to see it at work.",
            bundle: .module, comment: "The pane's prompt while no package is picked")
    }

    static var adaptiveShellSummary: String {
        String(
            localized: "sentence.adaptiveShell", defaultValue: "The sidebar, pane and pages.",
            bundle: .module, comment: "One line on what the AdaptiveShell package gives an app")
    }

    static var storybookSummary: String {
        String(
            localized: "sentence.storybook", defaultValue: "The catalog of every preview.",
            bundle: .module, comment: "One line on what the Storybook package gives an app")
    }

    static var inPane: String {
        String(
            localized: "sentence.inPane", defaultValue: "This pane sits beside the sidebar.",
            bundle: .module, comment: "AdaptiveShell's detail when it shows in a wide window's pane")
    }

    static var onStack: String {
        String(
            localized: "sentence.onStack", defaultValue: "This page sits on the phone's stack.",
            bundle: .module, comment: "AdaptiveShell's detail when a phone pushes it over the list")
    }
}
