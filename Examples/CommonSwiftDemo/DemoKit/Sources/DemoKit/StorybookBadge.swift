import Foundation
import Storybook
import StorybookKit
import SwiftUI

/// Storybook's badge pages, listed under this file's name, each a sidebar row in one freshness
/// state. The strip the catalog draws above each page shows its Then line, dates and age scale.
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
                SampleRow(badge: .added(.now.addingTimeInterval(-40 * day)))
            }
        ]
    }

    private static let day: TimeInterval = 24 * 60 * 60
}

/// One sidebar row, as the catalog draws it, on a grouped background.
private struct SampleRow: View {
    let badge: StorybookBadge?

    var body: some View {
        StorybookBadgeView(badge, id: "0012.4", label: DemoStorybook.sample(of: .storybook))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: 360)
            .background(.fill.quaternary, in: .rect(cornerRadius: 12))
            .padding()
    }
}
