import SwiftUI
import Theme

extension View {
    /// Draws this sample content as a breathing placeholder while `active`.
    /// VoiceOver reads `label` instead of the sample, and taps pass through it.
    public func loadingPlaceholder(_ active: Bool = true, label: String = "Loading") -> some View {
        modifier(LoadingPlaceholder(active: active, label: label))
    }
}

/// Every modifier applies whether or not it is active, so toggling keeps the content's state.
private struct LoadingPlaceholder: ViewModifier {
    let active: Bool
    let label: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dim = false

    func body(content: Content) -> some View {
        let breathing = active && !reduceMotion
        content
            .redacted(reason: active ? .placeholder : [])
            .opacity(dim ? 0.4 : 1)
            .allowsHitTesting(!active)
            .accessibilityHidden(active)
            .overlay {
                if active {
                    Rectangle().fill(.clear)
                        .accessibilityElement()
                        .accessibilityLabel(label)
                }
            }
            .animation(breathing ? .easeInOut(duration: 0.9).repeatForever() : .default, value: dim)
            .onChange(of: breathing, initial: true) { dim = breathing }
    }
}
