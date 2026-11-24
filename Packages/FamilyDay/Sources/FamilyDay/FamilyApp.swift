/// An app of the May Journal family that writes a row into a day, or opens at one.
public enum FamilyApp: String, CaseIterable, Identifiable, Codable, Sendable {
    case mayCalendar
    case listTotal
    case captions
    case outOfAHat
    case mayJournals
    case photoPortal

    public var id: String { rawValue }

    /// The app's name on the home screen, which a row's kicker starts with.
    public var name: String {
        switch self {
        case .mayCalendar: "May Calendar"
        case .listTotal: "List Total"
        case .captions: "Captions"
        case .outOfAHat: "Out of a Hat"
        case .mayJournals: "May Journals"
        case .photoPortal: "PhotoPortal"
        }
    }

    /// The URL scheme the app answers. Out of a Hat, May Journals and PhotoPortal already register
    /// theirs; the other apps register these when they adopt a day.
    public var scheme: String {
        switch self {
        case .mayCalendar: "maycalendar"
        case .listTotal: "listtotal"
        case .captions: "mayphotos"
        case .outOfAHat: "secretgifts"
        case .mayJournals: "mayjournals"
        case .photoPortal: "photoportal"
        }
    }

    /// The SF Symbol a row shows before the sender's name, until each app's icon replaces it.
    public var systemImage: String {
        switch self {
        case .mayCalendar: "calendar"
        case .listTotal: "list.bullet.rectangle"
        case .captions: "photo.on.rectangle"
        case .outOfAHat: "gift"
        case .mayJournals: "book.closed"
        case .photoPortal: "person.crop.square"
        }
    }
}
