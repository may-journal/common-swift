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

    static var openSettings: String {
        String(
            localized: "action.openSettings", defaultValue: "Open Settings", bundle: .module,
            comment: "Action: opens the demo's Settings page from the Storybook package")
    }

    static var back: String {
        String(
            localized: "action.back", defaultValue: "Back", bundle: .module,
            comment: "Action: closes the top page of a shell sample in the Storybook catalog")
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

    static var familyDaySummary: String {
        String(
            localized: "sentence.familyDay", defaultValue: "One day's rows, each opening its app.",
            bundle: .module, comment: "One line on what the FamilyDay package gives an app")
    }

    static var storybookSummary: String {
        String(
            localized: "sentence.storybook", defaultValue: "The catalog of every preview.",
            bundle: .module, comment: "One line on what the Storybook package gives an app")
    }

    static var nothingOpened: String {
        String(
            localized: "sentence.nothingOpened", defaultValue: "Nothing opened yet.",
            bundle: .module, comment: "FamilyDay's sample before a row or the chip opens an app")
    }

    /// "Captions opened at 2026-12-12.": the app a row or the chip opened, and the day.
    static func opened(_ app: String, at day: String) -> String {
        let format = String(
            localized: "sentence.opened", defaultValue: "%1$@ opened at %2$@.", bundle: .module,
            comment: "FamilyDay's sample after a tap: the app that opened and the day it opened at")
        return String.localizedStringWithFormat(format, app, day)
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
