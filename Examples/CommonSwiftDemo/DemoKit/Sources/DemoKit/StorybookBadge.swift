import Foundation
import Storybook
import StorybookKit
import SwiftUI

/// Storybook's badge pages, listed under this file's name, each a row with one badge or none.
/// The strip the catalog draws above each page shows its Then line and dates.
enum StorybookBadgePage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0015.1 New") { SampleRow(badge: .new) },
            BookPage(title: "0015.2 Changed") {
                SampleRow(badge: .changed(.now.addingTimeInterval(-2 * day)))
            },
            BookPage(title: "0015.3 Added") {
                SampleRow(badge: .added(.now.addingTimeInterval(-16 * day)))
            },
            BookPage(title: "0015.4 Acceptance above") { StorybookAcceptanceCard("0015.4") },
            BookPage(title: "0015.5 No history") { SampleRow(badge: nil) },
            BookPage(title: "0015.8 Added only") {
                StorybookBadgeView(.added(.now.addingTimeInterval(-16 * day))).padding()
            }
        ]
    }

    private static let day: TimeInterval = 24 * 60 * 60
}

/// A sidebar-style row for the demo's Storybook page: its ID and label, then the badge, if
/// any.
private struct SampleRow: View {
    let badge: StorybookBadge?

    var body: some View {
        HStack(spacing: 10) {
            Text(verbatim: "0012.4")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
            Text(DemoStorybook.sample(of: .storybook))
            Spacer(minLength: 0)
            if let badge { StorybookBadgeView(badge) }
        }
        .padding()
    }
}
