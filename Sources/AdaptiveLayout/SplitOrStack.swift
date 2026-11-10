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
    @State private var widthClass: WidthClass?
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

    /// One structure for both widths, so `primary` keeps its state across the breakpoint.
    public var body: some View {
        HStack(spacing: 0) {
            primary.frame(maxWidth: .infinity, maxHeight: .infinity)
            if widthClass == .wide, showsDetail {
                Rectangle().fill(theme.palette.line).frame(width: 1)
                detail
                    .containerRelativeFrame(.horizontal) { width, _ in width * detailFraction }
                    .frame(maxHeight: .infinity)
            }
        }
        // Only a narrow container pushes, and only once its width is known. A wide one pops a
        // pushed detail into its pane without writing `false` to `showsDetail`.
        .navigationDestination(isPresented: pushes) { detail }
        .onWidthClassChange(breakpoint: breakpoint) { widthClass = $0 }
    }

    private var pushes: Binding<Bool> {
        widthClass == .narrow ? $showsDetail : .constant(false)
    }
}
