import Foundation

/// The header buttons' names and the values they step through.
extension StorybookWords {
    static var device: String {
        String(
            localized: "noun.device", defaultValue: "Device", bundle: .module,
            comment: "Noun: the Storybook header button that picks the device frame")
    }

    static var rotate: String {
        String(
            localized: "verb.rotate", defaultValue: "Rotate", bundle: .module,
            comment: "Verb: the Storybook button that turns the device frame")
    }

    static var textSize: String {
        String(
            localized: "noun.textSize", defaultValue: "Text size", bundle: .module,
            comment: "Noun: the Storybook header button that picks the previews' text size")
    }

    static var dataLength: String {
        String(
            localized: "noun.dataLength", defaultValue: "Data length", bundle: .module,
            comment: "Noun: the Storybook header button that picks how much sample data shows")
    }

    static var appearance: String {
        String(
            localized: "noun.appearance", defaultValue: "Appearance", bundle: .module,
            comment: "Noun: the Storybook header button that flips light and dark")
    }

    static var dark: String {
        String(
            localized: "name.dark", defaultValue: "Dark", bundle: .module,
            comment: "Name: the dark appearance, as the Storybook appearance button's value")
    }

    static var light: String {
        String(
            localized: "name.light", defaultValue: "Light", bundle: .module,
            comment: "Name: the light appearance, as the Storybook appearance button's value")
    }

    static var autoDevice: String {
        String(
            localized: "name.autoDevice", defaultValue: "Auto, This Screen", bundle: .module,
            comment: "Name: the Storybook device choice that draws on this screen, unframed")
    }

    static var defaultText: String {
        String(
            localized: "name.defaultText", defaultValue: "Default text", bundle: .module,
            comment: "Name: the previews draw at the device's own text size")
    }

    static var largeText: String {
        String(
            localized: "name.largeText", defaultValue: "Large text", bundle: .module,
            comment: "Name: the previews draw at a large text size")
    }

    static var largestText: String {
        String(
            localized: "name.largestText", defaultValue: "Largest text", bundle: .module,
            comment: "Name: the previews draw at the largest accessibility text size")
    }

    static var emptyData: String {
        String(
            localized: "name.emptyData", defaultValue: "Empty data", bundle: .module,
            comment: "Name: the previews show no sample data")
    }

    static var shortData: String {
        String(
            localized: "name.shortData", defaultValue: "Short data", bundle: .module,
            comment: "Name: the previews show short sample data")
    }

    static var longData: String {
        String(
            localized: "name.longData", defaultValue: "Long data", bundle: .module,
            comment: "Name: the previews show long sample data")
    }

    static var portrait: String {
        String(
            localized: "name.portrait", defaultValue: "Portrait", bundle: .module,
            comment: "Name: the device frame held upright")
    }

    static var landscape: String {
        String(
            localized: "name.landscape", defaultValue: "Landscape", bundle: .module,
            comment: "Name: the device frame held on its side")
    }
}
