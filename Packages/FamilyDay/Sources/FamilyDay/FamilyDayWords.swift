import Foundation

/// The package's own words, as entries of its String Catalog.
enum FamilyDayWords {
    /// "Opens in Captions": the hint VoiceOver reads after a row's or a chip's label.
    static func opens(in app: FamilyApp) -> String {
        let format = String(
            localized: "hint.opensIn", defaultValue: "Opens in %@", bundle: .module,
            comment: "Hint: a day's row or chip opens this app, named by its home screen name")
        return String.localizedStringWithFormat(format, app.name)
    }
}
