import AdaptiveShell
import FamilyDay
import Foundation
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0019: a day's row or chip opens the app that made it, at that day.
extension FamilyDayTests {
    @MainActor
    @Suite struct Opening {
        /// Saturday 12 December 2026, as Captions' day line keys it.
        static let saturday = DayKey("2026-12-12")

        /// Renders a sibling's day page beside May Calendar and Captions, after `arrived` reached
        /// both, as a cold launch hands them a link.
        static func launch(after arrived: URL? = nil) throws -> (Screen, User) {
            let day = try #require(saturday)
            let row = DayRow(
                sender: .captions, day: day, title: "Jo found the last good squash",
                kicker: "4 photos, 3 with words")
            let calendar = PendingOpen(app: .mayCalendar)
            let captions = PendingOpen(app: .captions)
            if let arrived {
                calendar.open(arrived)
                captions.open(arrived)
            }
            let screen = try Screen.render {
                Family(row: row, calendar: calendar, captions: captions)
            }
            return (screen, User(screen))
        }

        @Test func test0019_1() async throws {
            let (screen, user) = try Self.launch()
            try await user.taps(.button("Jo found the last good squash"))
            try await user.sees(.text("Captions opened 2026-12-12"))
            try await user.sees(.text("May Calendar opened nothing"))
            try screen.close()
        }

        @Test func test0019_2() async throws {
            let (screen, user) = try Self.launch()
            try await user.sees(.button("Sat 12 Dec"))
            try screen.close()
        }

        @Test func test0019_3() async throws {
            let (screen, user) = try Self.launch()
            try await user.taps(.button("Sat 12 Dec"))
            try await user.sees(.text("May Calendar opened 2026-12-12"))
            try await user.sees(.text("Captions opened nothing"))
            try screen.close()
        }

        @Test func test0019_4() async throws {
            let day = try #require(Self.saturday)
            let (screen, user) = try Self.launch(after: DayLink(.listTotal, day: day).url)
            try await user.sees(.text("Captions opened nothing"))
            try await user.sees(.text("May Calendar opened nothing"))
            try screen.close()
        }
    }
}

/// Two apps of the family on one screen, under a sibling's day page with the chip and a row. The
/// system hands each link to both apps here, and each opens only its own.
private struct Family: View {
    let row: DayRow
    let calendar: PendingOpen<DayLink>
    let captions: PendingOpen<DayLink>
    @State private var calendarOpened: DayLink?
    @State private var captionsOpened: DayLink?

    var body: some View {
        VStack {
            DayChip(row.day)
            DayRowView(row)
            Text(verbatim: Self.opened(.mayCalendar, calendarOpened))
            Text(verbatim: Self.opened(.captions, captionsOpened))
        }
        .environment(\.locale, Locale(identifier: "en_GB"))
        .environment(\.calendar, Calendar(identifier: .gregorian))
        .environment(\.openURL, OpenURLAction { link in
            calendar.open(link)
            captions.open(link)
            return .handled
        })
        .opensRequests(calendar) { calendarOpened = $0 }
        .opensRequests(captions) { captionsOpened = $0 }
    }

    /// What one app opened, such as "Captions opened 2026-12-12".
    static func opened(_ app: FamilyApp, _ link: DayLink?) -> String {
        "\(app.name) opened \(link.map { "\($0.day)" } ?? "nothing")"
    }
}
