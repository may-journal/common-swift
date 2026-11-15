import Dispatch
import SwiftUI

extension Binding {
    /// Opens `page` when it isn't showing and closes it when it is. Closing also drops any page
    /// pushed above it, so the pane shows what it did before. A different open page is replaced,
    /// never stacked on, so Back never finds a stale page. Call it from the sidebar row's action,
    /// on the shell's path binding.
    @MainActor
    public func toggle<Page: Hashable>(_ page: Page) where Value == [Page] {
        if let index = wrappedValue.firstIndex(of: page) {
            wrappedValue.removeSubrange(index...)
        } else if wrappedValue.isEmpty {
            wrappedValue = [page]
        } else {
            // The stack drops a path whose pages change in place, so it closes the open page
            // first and opens the new one on the next turn.
            wrappedValue = []
            DispatchQueue.main.async { wrappedValue = [page] }
        }
    }
}

extension Optional where Wrapped: Equatable {
    /// Picks `item`, or clears the pick when `item` is already picked, so the pane shows its empty
    /// prompt. Call it from the sidebar row's action.
    public mutating func toggle(_ item: Wrapped) {
        self = self == item ? nil : item
    }
}
