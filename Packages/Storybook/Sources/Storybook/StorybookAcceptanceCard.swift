import SwiftUI

/// The page for an acceptance with no screen, such as a release rule: its ID and bundled Then
/// line. A build without history shows the ID alone.
public struct StorybookAcceptanceCard: View {
    private let id: String
    private let then: String?

    public init(_ id: String, history: StorybookHistory? = .bundled()) {
        self.id = id
        then = history?.acceptances[id]?.then
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: id)
                .font(.headline.monospacedDigit())
            if let then {
                Text(verbatim: then)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: 360, alignment: .leading)
        .padding(16)
        .background(.background.secondary, in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .padding()
    }
}
