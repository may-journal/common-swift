import SwiftUI
import Theme

extension View {
    /// Draws this sample content as a breathing placeholder while `active`.
    /// VoiceOver reads `label` instead of the sample, and taps pass through it.
    public func loadingPlaceholder(_ active: Bool = true, label: String = "Loading") -> some View {
        modifier(LoadingPlaceholder(active: active, label: label))
    }
}

private struct LoadingPlaceholder: ViewModifier {
    let active: Bool
    let label: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dim = false

    func body(content: Content) -> some View {
        if active {
            content
                .redacted(reason: .placeholder)
                .opacity(dim ? 0.4 : 1)
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label)
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(.easeInOut(duration: 0.9).repeatForever()) { dim = true }
                }
        } else {
            content
        }
    }
}
