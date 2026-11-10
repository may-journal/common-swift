import SwiftUI
import Theme

/// Two panes side by side when the container is wide, and the detail pushed when it is narrow.
/// On a narrow container the detail pushes onto the enclosing `NavigationStack`, so Back
/// writes `false` to `showsDetail`.
public struct SplitOrStack<Primary: View, Detail: View>: View {
    @Binding var showsDetail: Bool
    let breakpoint: CGFloat
    let detailFraction: CGFloat
    let primary: Primary
    let detail: Detail
    @State private var width: CGFloat?
    @Environment(\.theme) private var theme

    /// Splits at `breakpoint` points, giving the detail `detailFraction` of a wide container.
    public init(
        showsDetail: Binding<Bool>, breakpoint: CGFloat = WidthClass.breakpoint,
        detailFraction: CGFloat = 1.0 / 3.0, @ViewBuilder primary: () -> Primary,
        @ViewBuilder detail: () -> Detail
    ) {
        _showsDetail = showsDetail
        self.breakpoint = breakpoint
        self.detailFraction = detailFraction
        self.primary = primary()
        self.detail = detail()
    }

    public var body: some View {
        Group {
            if let width, WidthClass(width: width, breakpoint: breakpoint) == .wide {
                split(width)
            } else if width != nil {
                primary.navigationDestination(isPresented: $showsDetail) { detail }
            } else {
                // Nothing pushes before the width is known, so a wide screen never starts stacked.
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onWidthChange { width = $0 }
    }

    private func split(_ width: CGFloat) -> some View {
        HStack(spacing: 0) {
            primary.frame(maxWidth: .infinity, maxHeight: .infinity)
            if showsDetail {
                Rectangle().fill(theme.palette.line).frame(width: 1)
                detail.frame(width: width * detailFraction).frame(maxHeight: .infinity)
            }
        }
    }
}
