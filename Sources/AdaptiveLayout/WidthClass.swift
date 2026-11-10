import SwiftUI

/// Whether a container is narrow, like a phone, or wide, like a pad or a Mac window.
/// It comes from the container's measured width, so it holds on the Mac, which has no size class.
public enum WidthClass: Sendable, Equatable {
    case narrow
    case wide

    /// The width a container must reach to count as wide, in points.
    public static let breakpoint: CGFloat = 700

    /// The class of a container `width` points wide, given the wide `breakpoint`.
    public init(width: CGFloat, breakpoint: CGFloat = WidthClass.breakpoint) {
        self = width >= breakpoint ? .wide : .narrow
    }
}

extension View {
    /// Calls `action` with this view's width class, only when it flips at `breakpoint`.
    func onWidthClassChange(
        breakpoint: CGFloat, _ action: @escaping (WidthClass) -> Void
    ) -> some View {
        onGeometryChange(for: WidthClass.self) {
            WidthClass(width: $0.size.width, breakpoint: breakpoint)
        } action: {
            action($0)
        }
    }
}
