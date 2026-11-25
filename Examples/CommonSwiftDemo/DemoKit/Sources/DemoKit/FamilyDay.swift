import AdaptiveShell
import FamilyDay
import Foundation
import StorybookKit
import SwiftUI

/// FamilyDay's catalog pages, listed under their requirements. Each sample routes the
/// links its rows and chip open to every app's `PendingOpen`, and says which app opened.
enum FamilyDayPage {
    /// Saturday 12 December 2026, the day every sample shows.
    static let saturday = DayKey("2026-12-12") ?? DayKey(.now)

    /// One row for each sender app, as each would write it into Saturday.
    static let rows: [DayRow] = FamilyApp.allCases.map(row)

    /// The sample for the packages page: Saturday's rows.
    @MainActor @ViewBuilder static var sample: some View { FamilyDaySample(rows: rows) }

    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0019.1 Row opens Captions") { FamilyDaySample(rows: [row(.captions)]) },
            BookPage(title: "0019.2 Chip for 2026-12-12") { DayChip(saturday) },
            BookPage(title: "0019.3 Chip opens May Calendar") { FamilyDaySample(rows: []) },
            BookPage(title: "0019.4 List Total link at Captions") {
                FamilyDaySample(
                    rows: [], listening: [.captions], arrived: DayLink(.listTotal, day: saturday).url)
            },
            BookPage(title: "0019.5 Row for each app") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(FamilyApp.allCases, id: \.self) { app in
                        LabeledSample(label: "\(app.name) row") { DayRowView(row(app)) }
                    }
                }
                .padding()
            }
        ]
    }

    /// The row `app` writes into Saturday.
    static func row(_ app: FamilyApp) -> DayRow {
        switch app {
        case .mayCalendar:
            DayRow(sender: app, day: saturday, title: "Farmers market", kicker: "9:10, 1 h 20 m")
        case .listTotal:
            DayRow(sender: app, day: saturday, title: "Dinner groceries", kicker: "receipt, $84.12")
        case .captions:
            DayRow(
                sender: app, day: saturday, title: "Jo found the last good squash",
                kicker: "4 photos, 3 with words")
        case .outOfAHat:
            DayRow(sender: app, day: saturday, title: "You drew Marcus", kicker: "5 going")
        case .mayJournals:
            DayRow(sender: app, day: saturday, title: "Farmers market, morning", kicker: "draft")
        case .photoPortal:
            DayRow(sender: app, day: saturday, title: "Lena sent a photo", kicker: "on my way")
        }
    }
}

/// Saturday's chip over its rows, and a line naming the app the last tap opened.
struct FamilyDaySample: View {
    let rows: [DayRow]
    @State private var apps: [FamilyApp: PendingOpen<DayLink>]
    @State private var opened: DayLink?

    /// `listening` are the apps on the device; `arrived` is a link they heard before showing.
    init(rows: [DayRow], listening: [FamilyApp] = FamilyApp.allCases, arrived: URL? = nil) {
        self.rows = rows
        let apps = Dictionary(uniqueKeysWithValues: listening.map { ($0, PendingOpen(app: $0)) })
        if let arrived { apps.values.forEach { $0.open(arrived) } }
        _apps = State(initialValue: apps)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DayChip(FamilyDayPage.saturday)
            ForEach(rows) { DayRowView($0) }
            Text(opened.map { DemoWords.opened($0.app.name, at: "\($0.day)") } ?? DemoWords.nothingOpened)
                .foregroundStyle(.secondary)
        }
        .padding()
        .environment(\.openURL, OpenURLAction { link in
            apps.values.forEach { $0.open(link) }
            return .handled
        })
        .background {
            // Each app hands over what it held, as its window's root would.
            ForEach(Array(apps.keys), id: \.self) { app in
                if let requests = apps[app] {
                    Color.clear.opensRequests(requests) { opened = $0 }
                }
            }
        }
    }
}
