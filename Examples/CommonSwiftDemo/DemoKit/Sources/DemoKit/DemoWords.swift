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
