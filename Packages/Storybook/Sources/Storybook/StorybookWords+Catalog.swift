import Foundation

/// The device names and the catalog's empty states.
extension StorybookWords {
    static var auto: String {
        String(
            localized: "name.device.auto", defaultValue: "Auto", bundle: .module,
            comment: "Name: the Storybook device choice that draws on this screen")
    }

    static var iPhone: String {
        String(
            localized: "name.device.iPhone", defaultValue: "iPhone", bundle: .module,
            comment: "Name: the iPhone device frame in Storybook")
    }

    static var iPhoneDuo: String {
        String(
            localized: "name.device.iPhoneDuo", defaultValue: "iPhone Duo", bundle: .module,
            comment: "Name: the open iPhone Duo device frame in Storybook")
    }

    static var iPad: String {
        String(
            localized: "name.device.iPad", defaultValue: "iPad", bundle: .module,
            comment: "Name: the iPad device frame in Storybook")
    }

    static var mac: String {
        String(
            localized: "name.device.mac", defaultValue: "Mac", bundle: .module,
            comment: "Name: the Mac window frame in Storybook")
    }

    static var noPreviewOpened: String {
        String(
            localized: "title.noPreviewOpened", defaultValue: "No preview opened",
            bundle: .module,
            comment: "Title: the page a Storybook launch named does not exist")
    }

    static var choosePreview: String {
        String(
            localized: "title.choosePreview", defaultValue: "Choose a preview", bundle: .module,
            comment: "Title: the Storybook detail pane before a page is picked")
    }

    static var pickPage: String {
        String(
            localized: "sentence.pickPage", defaultValue: "Pick a page from the list.",
            bundle: .module,
            comment: "Sentence: under the Storybook detail pane's empty title")
    }

    /// The launch named a page that several previews share, listed by file and line.
    static func manyPages(named name: String, _ places: [String]) -> String {
        let list = places.formatted(.list(type: .and))
        return String(
            localized: "sentence.manyPages",
            defaultValue: """
                Several previews are named \u{201C}\(name)\u{201D}: \(list). \
                Add --storybook-file and --storybook-line.
                """,
            bundle: .module,
            comment: "Sentence: a Storybook launch named a page that several previews share")
    }

    /// The launch named a page or component that does not exist.
    static func noPage(named name: String) -> String {
        String(
            localized: "sentence.noPage",
            defaultValue: "No single preview or component is named \u{201C}\(name)\u{201D}.",
            bundle: .module,
            comment: "Sentence: a Storybook launch named a page that does not exist")
    }
}
