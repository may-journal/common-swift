import SwiftUI
import Theme

/// A small capsule with a spinner and a label, laid over content while a task runs.
public struct StatusPill: View {
    let title: String
    let busy: Bool
    @Environment(\.theme) private var theme

    /// A pill reading `title`, with a spinner while `busy`.
    public init(_ title: String, busy: Bool = true) {
        self.title = title
        self.busy = busy
    }

    public var body: some View {
        HStack(spacing: theme.spacing.small) {
            if busy { ProgressView().controlSize(.small) }
            Text(title)
                .font(theme.type.caption, weight: .medium)
                .foregroundStyle(theme.palette.ink)
        }
        .padding(.vertical, theme.spacing.small)
        .padding(.horizontal, theme.spacing.medium)
        .background(.regularMaterial, in: Capsule())
        .overlay { Capsule().strokeBorder(theme.palette.line, lineWidth: 1) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(busy ? "\(title), in progress" : title)
    }
}
