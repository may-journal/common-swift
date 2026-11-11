import SwiftUI

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

/// The few colors and placements that differ between iOS and the Mac, named once.
extension Color {
    /// Behind a page: the screen's own background.
    static var storybookPage: Color {
        #if os(iOS)
            Color(uiColor: .systemBackground)
        #else
            Color(nsColor: .textBackgroundColor)
        #endif
    }

    /// Behind a grid of cards.
    static var storybookGrid: Color {
        #if os(iOS)
            Color(uiColor: .secondarySystemBackground)
        #else
            Color(nsColor: .windowBackgroundColor)
        #endif
    }

    /// Around a device frame smaller than the pane.
    static var storybookDesk: Color {
        #if os(iOS)
            Color(uiColor: .systemGray5)
        #else
            Color(nsColor: .underPageBackgroundColor)
        #endif
    }
}

extension ToolbarItemPlacement {
    /// Where the header's buttons sit: the trailing end of the bar.
    static var storybookTrailing: ToolbarItemPlacement {
        #if os(iOS)
            .topBarTrailing
        #else
            .primaryAction
        #endif
    }

    /// Where previous and next sit: the bottom bar on iOS, the bar's end on the Mac.
    static var storybookStepper: ToolbarItemPlacement {
        #if os(iOS)
            .bottomBar
        #else
            .automatic
        #endif
    }
}

extension View {
    /// An inline title on iOS; the Mac has only one kind.
    func storybookInlineTitle() -> some View {
        #if os(iOS)
            navigationBarTitleDisplayMode(.inline)
        #else
            self
        #endif
    }
}
