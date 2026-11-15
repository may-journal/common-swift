import SwiftUI

/// A sidebar row that opens what it names and closes it on the next tap, at every width.
/// It is the system's `Button`, tagged with its value, and reads as selected while open.
public struct ShellRow<Value: Hashable, Label: View>: View {
    private let value: Value
    private let isOpen: Bool
    private let toggle: @MainActor () -> Void
    private let label: Label

    /// A row for an item the pane shows, which a tap picks or unpicks. A tap also closes a
    /// page that covers the pane.
    public init<Page: Hashable>(
        _ item: Value, picked: Binding<Value?>, path: Binding<[Page]>,
        @ViewBuilder label: () -> Label
    ) {
        value = item
        isOpen = picked.wrappedValue == item && path.wrappedValue.isEmpty
        toggle = {
            if path.wrappedValue.isEmpty {
                picked.wrappedValue.toggle(item)
            } else {
                path.wrappedValue = []
                picked.wrappedValue = item
            }
        }
        self.label = label()
    }

    /// A row for a page. A tap opens it, closes it with every page above it, or replaces a
    /// different open page.
    public init(_ page: Value, path: Binding<[Value]>, @ViewBuilder label: () -> Label) {
        value = page
        isOpen = path.wrappedValue.first == page
        toggle = { path.toggle(page) }
        self.label = label()
    }

    public var body: some View {
        Button(action: toggle) { label }
            .tag(value)
            .accessibilityAddTraits(isOpen ? .isSelected : [])
    }
}
