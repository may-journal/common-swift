import SwiftUI

/// The Settings row that opens the catalog, for an app whose own Version row calls `tapsVersion()`.
/// The app asks `resolve()` as its Settings appear, since an absent row can't.
public struct StorybookRowSection: View {
    private let availability: StorybookAvailability

    public init(_ availability: StorybookAvailability) {
        self.availability = availability
    }

    private var configuration: StorybookConfiguration { availability.configuration }

    public var body: some View {
        if availability.isEnabled { section }
    }

    private var section: some View {
        Section {
            // It opens the root cover, since a lazy Form row would drop a cover of its own.
            Button {
                availability.presentsCatalog()
            } label: {
                HStack {
                    Text(configuration.labels.storybook)
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .contentShape(.rect)
            }
            .accessibilityIdentifier(configuration.identifiers.storybookRow)
        } footer: {
            Text(configuration.labels.footer)
        }
    }
}
