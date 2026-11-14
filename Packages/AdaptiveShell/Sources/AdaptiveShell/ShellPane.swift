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

extension ShellPane where Empty == ContentUnavailableView<Label<Text, Image>, Text?, EmptyView> {
    /// A pane whose empty state is the system's `ContentUnavailableView` with the app's words.
    /// `empty:` takes an app's own view instead.
    public init(
        selection: Item?,
        title: String,
        systemImage: String,
        message: String? = nil,
        @ViewBuilder detail: @escaping (Item) -> Detail
    ) {
        self.selection = selection
        self.detail = detail
        empty = {
            ContentUnavailableView(
                title, systemImage: systemImage, description: message.map { Text($0) })
        }
    }
}
