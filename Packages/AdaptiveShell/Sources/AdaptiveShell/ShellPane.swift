import SwiftUI

/// The pane's content: the picked item's detail, or the app's prompt while nothing is picked.
/// Either fills the pane.
public struct ShellPane<Item, Detail: View, Empty: View>: View {
    private let selection: Item?
    private let detail: (Item) -> Detail
    private let empty: () -> Empty

    public init(
        selection: Item?,
        @ViewBuilder detail: @escaping (Item) -> Detail,
        @ViewBuilder empty: @escaping () -> Empty
    ) {
        self.selection = selection
        self.detail = detail
        self.empty = empty
    }

    public var body: some View {
        Group {
            if let selection {
                detail(selection)
            } else {
                empty()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
