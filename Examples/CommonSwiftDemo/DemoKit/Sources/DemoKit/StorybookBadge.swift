import Foundation
import Storybook
import StorybookKit
import SwiftUI

/// Storybook's badge pages, each a sidebar row in one freshness state, aged at a fixed build day.
/// With the header's Freshness on, the panel above each page shows its Then line and age scale.
enum StorybookBadgePage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0015.1 New") { SampleRow(badge: .new) },
            BookPage(title: "0015.2 Changed") { SampleRow(badge: changed(days: 2)) },
            BookPage(title: "0015.3 Weeks old") { SampleRow(badge: changed(days: 16)) },
            BookPage(title: "0015.4 Acceptance above") { StorybookAcceptanceCard("0015.4") },
            BookPage(title: "0015.5 No history") { SampleRow(badge: nil) },
            BookPage(title: "0015.8 Commits ago") { SampleRow(badge: changed(days: 40)) }
        ]
    }

    /// The badge of code that changed `days` before a build made on Nov 1, 2026.
    private static func changed(days: Int) -> StorybookBadge {
        let age = Duration.seconds(days * 24 * 60 * 60)
        let build = Date(timeIntervalSince1970: 1_793_534_400)
        return .changed(build.addingTimeInterval(-Double(age.components.seconds)), age: age)
    }
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
