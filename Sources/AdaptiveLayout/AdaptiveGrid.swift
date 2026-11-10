import SwiftUI
import Theme

/// A grid that fills each row with as many tiles as fit, none narrower than `minimumWidth`.
/// Tiles share the leftover width, and the gaps are the theme's small spacing.
public struct AdaptiveGrid<Data: RandomAccessCollection, Cell: View>: View
where Data.Element: Identifiable {
    let data: Data
    let minimumWidth: CGFloat
    let cell: (Data.Element) -> Cell
    @Environment(\.theme) private var theme

    /// A grid of `data`, each tile at least `minimumWidth` points wide.
    public init(
        _ data: Data, minimumWidth: CGFloat, @ViewBuilder cell: @escaping (Data.Element) -> Cell
    ) {
        self.data = data
        self.minimumWidth = minimumWidth
        self.cell = cell
    }

    public var body: some View {
        let gap = theme.spacing.small
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: minimumWidth), spacing: gap)], spacing: gap
        ) {
            ForEach(data) { item in cell(item) }
        }
    }
}
