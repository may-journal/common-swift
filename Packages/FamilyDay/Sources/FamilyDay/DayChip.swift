import SwiftUI

/// The chip a sibling app shows at the top of a day's page. It names the day in the person's
/// calendar, and a tap returns to that day in May Calendar, the day's timeline.
public struct DayChip: View {
    private let day: DayKey
    @Environment(\.openURL) private var openURL
    @Environment(\.locale) private var locale
    @Environment(\.calendar) private var calendar

    public init(_ day: DayKey) {
        self.day = day
    }

    public var body: some View {
        Button {
            openURL(DayLink(.mayCalendar, day: day).url)
        } label: {
            Label {
                Text(verbatim: title)
            } icon: {
                Image(systemName: FamilyApp.mayCalendar.systemImage)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.fill.tertiary, in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: title))
        .accessibilityHint(FamilyDayWords.opens(in: .mayCalendar))
    }

    /// The day as "Sat 12 Dec", in the person's locale and calendar.
    private var title: String {
        let style = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
        return day.date(in: calendar.timeZone).formatted(style.weekday(.abbreviated).day().month(.abbreviated))
    }
}
