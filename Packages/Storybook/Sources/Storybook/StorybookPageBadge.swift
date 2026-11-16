import StorybookKit
import SwiftUI

/// The New capsule, in the accent color, which a page earns when the build's commit added
/// its acceptance.
struct StorybookNewCapsule: View {
    var body: some View {
        Text(StorybookWords.new)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.15), in: .capsule)
            .overlay { Capsule().strokeBorder(Color.accentColor) }
            .accessibilityIdentifier("storybook.badge.new")
    }
}

/// A page's badge on its own: the New capsule, or a caption saying when the page changed or
/// was added. The catalog's rows draw it, and a host can show it too.
public struct StorybookBadgeView: View {
    let badge: StorybookBadge

    public init(_ badge: StorybookBadge) {
        self.badge = badge
    }

    public var body: some View {
        if badge == .new {
            StorybookNewCapsule()
        } else {
            Text(StorybookWords.badge(badge))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// A page's sidebar row: its acceptance ID, its label, and the badge its history earns. New
/// sits at the end of the row; how long ago it changed, or when it was added, sits under the
/// label.
struct StorybookPageRow: View {
    let page: BookPage
    let catalog: StorybookCatalog

    var body: some View {
        let badge = catalog.badge(of: page)
        HStack(spacing: 10) {
            if let id = StorybookCatalog.acceptanceID(of: page) {
                Text(verbatim: id)
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(StorybookCatalog.shortTitle(of: page))
                if let badge, badge != .new { StorybookBadgeView(badge) }
            }
            Spacer(minLength: 0)
            if badge == .new { StorybookBadgeView(.new) }
        }
    }
}

/// Above a page whose name starts with an acceptance: the acceptance's ID and Then line, and
/// when it was added and changed. A build without history shows the ID alone.
struct StorybookAcceptanceStrip: View {
    let page: BookPage
    let catalog: StorybookCatalog

    var body: some View {
        if let id = StorybookCatalog.acceptanceID(of: page) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(StorybookCatalog.shortTitle(of: page))
                        .font(.title3.weight(.semibold))
                    if catalog.badge(of: page) == .new { StorybookNewCapsule() }
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(verbatim: id)
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                    if let then = catalog.then(of: page) {
                        Text(verbatim: then).font(.subheadline)
                    }
                }
                if let dates { Text(dates).font(.caption).foregroundStyle(.secondary) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.bar)
        }
    }

    /// "Added Oct 30, 2026 · Changed 2 days ago", or nil without history.
    private var dates: String? {
        guard let id = StorybookCatalog.acceptanceID(of: page),
            let acceptance = catalog.history?.acceptances[id]
        else { return nil }
        return StorybookWords.dates(acceptance)
    }
}
