import SwiftUI
import Theme

/// A centered symbol tile, title, message and optional button, drawn in the app's theme.
/// Empty and failed screens both use it.
public struct StatusView: View {
    let symbol: String
    let title: String
    let message: String
    let tint: Color?
    let action: StatusAction?
    @Environment(\.theme) private var theme

    /// A status with `symbol` drawn in `tint`, or in the theme's faint ink when `tint` is nil.
    public init(
        symbol: String, title: String, message: String, tint: Color? = nil,
        action: StatusAction? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        VStack(spacing: theme.spacing.large) {
            tile
            VStack(spacing: theme.spacing.small) {
                Text(title)
                    .font(theme.type.headline, weight: .bold)
                    .foregroundStyle(theme.palette.ink)
                Text(message)
                    .font(theme.type.body)
                    .foregroundStyle(theme.palette.mutedInk)
                    .multilineTextAlignment(.center)
            }
            if let action { button(action) }
        }
        .frame(maxWidth: theme.spacing.readableWidth)
        .padding(.horizontal, theme.spacing.xLarge)
    }

    private var tile: some View {
        let shape = RoundedRectangle(cornerRadius: theme.radii.large, style: .continuous)
        return shape.fill(theme.palette.sunken)
            .overlay { shape.strokeBorder(theme.palette.line, lineWidth: 1) }
            .frame(width: 76, height: 76)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: 28))
                    .foregroundStyle(tint ?? theme.palette.faintInk)
            }
            .accessibilityHidden(true)
    }

    private func button(_ action: StatusAction) -> some View {
        Button(action: action.run) {
            Text(action.title)
                .font(theme.type.body, weight: .semibold)
                .foregroundStyle(theme.palette.onAccent)
                .padding(.horizontal, theme.spacing.large)
                .padding(.vertical, theme.spacing.medium)
                .background(
                    theme.palette.accent,
                    in: RoundedRectangle(cornerRadius: theme.radii.medium, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// The button under a status: its title and what it runs.
public struct StatusAction {
    public let title: String
    public let run: () -> Void

    public init(_ title: String, run: @escaping () -> Void) {
        self.title = title
        self.run = run
    }
}

/// A failed load: its message and, when the caller can retry, a Try Again button.
public struct FailureView: View {
    let title: String
    let message: String
    let retry: (() -> Void)?
    @Environment(\.theme) private var theme

    public init(
        title: String = "Something went wrong", message: String, retry: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retry = retry
    }

    public var body: some View {
        StatusView(
            symbol: "exclamationmark.triangle", title: title, message: message,
            tint: theme.palette.danger, action: retry.map { StatusAction("Try Again", run: $0) })
    }
}
