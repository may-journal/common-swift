import Dispatch
import SwiftUI

extension Binding {
    /// Opens `page`, or closes it with every page above it when it shows; a different open page
    /// is replaced, so Back never finds a stale one.
    @MainActor
    public func toggle<Page: Hashable>(_ page: Page) where Value == [Page] {
        if let index = wrappedValue.firstIndex(of: page) {
            wrappedValue = Array(wrappedValue[..<index])
        } else if wrappedValue.isEmpty {
            wrappedValue = [page]
        } else {
            // The stack drops a path changed in place. Close the open page, then open the new one.
            wrappedValue = []
            DispatchQueue.main.async { wrappedValue = [page] }
        }
    }
}

extension Optional where Wrapped: Equatable {
    /// Picks `item`, or clears the pick when `item` is already picked.
    public mutating func toggle(_ item: Wrapped) {
        self = self == item ? nil : item
    }
}
