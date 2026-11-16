import StorybookKit
import SwiftUI

/// How fresh a page's code is at the build's commit, never by the clock, for its chip, meter
/// and header. It is 4 when new, then 3 within three days, 2 within two weeks, 1 within five.
struct StorybookFreshness: Equatable {
    /// The header's age scale spans five weeks before the build.
    static let scaleDays = 35.0

    let level: Int
    /// Days from the code's last change to the build's commit; none when it is new.
    let days: Double

    init(_ badge: StorybookBadge) {
        guard case .changed(_, let age) = badge else {
            level = 4
            days = 0
            return
        }
        days = Double(age.components.seconds) / (24 * 60 * 60)
        level =
            switch days {
            case ...3: 3
            case ...14: 2
            case ...Self.scaleDays: 1
            default: 0
            }
    }
}

/// The ID chip, which is the badge: one accent hue, filled for New and fading with age. A page
/// without history gets a dashed chip with no tint.
struct StorybookIDChip: View {
    let id: String
    let badge: StorybookBadge?
    var large = false

    @Environment(\.backgroundProminence) private var prominence

    var body: some View {
        let level = badge.map { StorybookFreshness($0).level }
        let tint = prominence == .increased ? Color.white : Color.accentColor
        Text(verbatim: id)
            .font((large ? Font.subheadline : .storybookDetail).monospacedDigit())
            .fontWeight(level == 4 ? .bold : .medium)
            .foregroundStyle(text(level))
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, large ? 10 : 8)
            .padding(.vertical, large ? 4 : 2)
            .background {
                if let level {
                    Capsule().fill(tint.opacity([0.07, 0.12, 0.2, 0.32, 1][level]))
                } else {
                    Capsule().strokeBorder(
                        .secondary, style: StrokeStyle(lineWidth: 1, dash: [3, 2.5]))
                }
            }
            .storybookNewIdentifier(badge == .new)
    }

    private func text(_ level: Int?) -> Color {
        switch level {
        case 4: prominence == .increased ? .accentColor : .white
        case nil: .secondary
        default: .primary
        }
    }
}

extension View {
    /// Tests find a New page by this identifier on its chip.
    @ViewBuilder func storybookNewIdentifier(_ isNew: Bool) -> some View {
        if isNew { accessibilityIdentifier("storybook.badge.new") } else { self }
    }
}

/// Four signal bars, as many lit as the page's freshness, so its age never rests on color.
struct StorybookMeter: View {
    let level: Int

    @Environment(\.backgroundProminence) private var prominence

    var body: some View {
        let tint = prominence == .increased ? Color.white : Color.accentColor
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<4, id: \.self) { bar in
                RoundedRectangle(cornerRadius: 1)
                    .fill(bar < level ? AnyShapeStyle(tint) : AnyShapeStyle(.quaternary))
                    .frame(width: 3, height: 4 + CGFloat(bar) * 2)
            }
        }
        .accessibilityHidden(true)
    }
}

/// The short age before the build, such as Now or 16d, beside the meter unless a card draws the
/// meter over its preview. VoiceOver reads it as 16 days before the build, and skips Now, which
/// the caption says in full.
struct StorybookAgeMeter: View {
    let badge: StorybookBadge
    var showsMeter = true

    var body: some View {
        let level = StorybookFreshness(badge).level
        let spoken = StorybookWords.spokenAge(badge)
        HStack(spacing: 6) {
            Text(verbatim: StorybookWords.age(badge))
                .font(Font.storybookDetail.monospacedDigit())
                .fontWeight(level == 4 ? .semibold : .regular)
                .foregroundStyle(level >= 2 ? .primary : .secondary)
                .fixedSize()
                .accessibilityLabel(Text(verbatim: spoken ?? ""))
                .accessibilityHidden(spoken == nil)
            if showsMeter { StorybookMeter(level: level) }
        }
    }
}

/// The words under a page's label: New in this build, Changed Oct 30, or No git history.
/// Fresh pages say it in the primary color, older ones in the secondary.
struct StorybookBadgeCaption: View {
    let badge: StorybookBadge?

    var body: some View {
        let level = badge.map { StorybookFreshness($0).level } ?? 0
        Text(StorybookWords.badge(badge))
            .font(.storybookDetail)
            .fontWeight(badge == .new ? .semibold : .regular)
            .foregroundStyle(level >= 2 ? .primary : .secondary)
            .lineLimit(1)
    }
}

/// A page's sidebar row: the ID chip, the label over its caption, then the age and meter. A
/// host can show it too.
public struct StorybookBadgeView: View {
    let badge: StorybookBadge?
    let id: String
    let label: String

    /// A row for the acceptance `id` and its page's `label`, with the badge its history earns.
    /// A build without history passes none.
    public init(_ badge: StorybookBadge?, id: String, label: String) {
        self.badge = badge
        self.id = id
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 10) {
            StorybookIDChip(id: id, badge: badge)
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: label).lineLimit(1)
                StorybookBadgeCaption(badge: badge)
            }
            .layoutPriority(1)
            Spacer(minLength: 4)
            if let badge { StorybookAgeMeter(badge: badge) }
        }
    }
}

/// A page's sidebar row: the badge row for a page named by an acceptance, else its name.
struct StorybookPageRow: View {
    let page: BookPage
    let catalog: StorybookCatalog

    var body: some View {
        if let id = StorybookCatalog.acceptanceID(of: page) {
            StorybookBadgeView(
                catalog.badge(of: page), id: id, label: StorybookCatalog.shortTitle(of: page))
        } else {
            Text(StorybookCatalog.shortTitle(of: page))
        }
    }
}

/// Above an acceptance's page while the header's Freshness is on: its chip, label, Then line,
/// dates and a five-week age scale. Without history the chip is dashed and the scale empty.
struct StorybookAcceptanceStrip: View {
    let page: BookPage
    let catalog: StorybookCatalog

    @AppStorage(StorybookFreshnessSetting.storageKey)
    private var freshness: StorybookFreshnessSetting = .hidden

    var body: some View {
        if freshness == .shown, let id = StorybookCatalog.acceptanceID(of: page) {
            let badge = catalog.badge(of: page)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    StorybookIDChip(id: id, badge: badge, large: true)
                    Text(StorybookCatalog.shortTitle(of: page))
                        .font(.title3.weight(.semibold))
                        .lineLimit(1)
                }
                if let then = catalog.then(of: page) {
                    Text(verbatim: then).font(.subheadline)
                }
                dates(badge, id: id)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VStack(spacing: 4) {
                    StorybookAgeScale(days: badge.map { StorybookFreshness($0).days })
                    HStack {
                        Text(StorybookWords.scaleStart)
                        Spacer()
                        Text(StorybookWords.scaleEnd)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                }
                .padding(.top, 4)
            }
            .padding(14)
            .frame(maxWidth: 520, alignment: .leading)
            .background(.fill.quaternary, in: .rect(cornerRadius: 12))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.bar)
        }
    }

    /// "Changed Oct 30, 2026 · 3 commits ago", led by New in this build when it is. Without
    /// history it says why there is no age.
    @ViewBuilder private func dates(_ badge: StorybookBadge?, id: String) -> some View {
        if let acceptance = catalog.history?.acceptances[id] {
            HStack(spacing: 4) {
                if badge == .new {
                    Text(StorybookWords.new).fontWeight(.semibold).foregroundStyle(.primary)
                    Text(verbatim: "·").accessibilityHidden(true)
                }
                Text(StorybookWords.changedOn(acceptance.changed))
                if acceptance.commitsAgo > 0 {
                    Text(verbatim: "·").accessibilityHidden(true)
                    Text(StorybookWords.commitsAgo(acceptance.commitsAgo))
                }
            }
        } else {
            Text(StorybookWords.noAge)
        }
    }
}

/// Five segments fading from This build to five weeks, with a knob at the page's age. Without
/// history they are gray with no knob, and VoiceOver reads the dates above instead.
struct StorybookAgeScale: View {
    let days: Double?

    private static let fade = [0.85, 0.55, 0.35, 0.2, 0.1]
    private static let knob: CGFloat = 12

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                HStack(spacing: 3) {
                    ForEach(Self.fade, id: \.self) { opacity in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                days == nil
                                    ? AnyShapeStyle(.quaternary)
                                    : AnyShapeStyle(Color.accentColor.opacity(opacity))
                            )
                            .frame(height: 8)
                    }
                }
                if let days {
                    Circle()
                        .fill(.primary)
                        .overlay { Circle().strokeBorder(.background, lineWidth: 2) }
                        .frame(width: Self.knob, height: Self.knob)
                        .offset(
                            x: (proxy.size.width - Self.knob)
                                * min(days, StorybookFreshness.scaleDays)
                                / StorybookFreshness.scaleDays)
                }
            }
            .frame(height: proxy.size.height)
        }
        .frame(height: Self.knob + 2)
        .accessibilityHidden(true)
    }
}
