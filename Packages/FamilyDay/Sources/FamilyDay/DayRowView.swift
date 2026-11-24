import SwiftUI

/// A day's row as every app draws it: the sender's symbol and kicker over a one-line title. A tap
/// opens the sender at that day, through the system's `openURL`.
public struct DayRowView: View {
    private let row: DayRow
    @Environment(\.openURL) private var openURL

    public init(_ row: DayRow) {
        self.row = row
    }

    public var body: some View {
        Button {
            openURL(row.link.url)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: row.sender.systemImage)
                    .foregroundStyle(.tint)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: "\(row.sender.name) · \(row.kicker)")
                        .font(.caption.smallCaps())
                        .foregroundStyle(.secondary)
                    Text(verbatim: row.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: row.title))
        .accessibilityValue(Text(verbatim: "\(row.sender.name), \(row.kicker)"))
        .accessibilityHint(FamilyDayWords.opens(in: row.sender))
    }
}
