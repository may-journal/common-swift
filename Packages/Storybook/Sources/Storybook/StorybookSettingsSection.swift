import SwiftUI

/// The Settings section an app drops in: the version row, then the row that opens the catalog.
/// Seven taps on Version unlock the catalog where the gate allows; elsewhere Version is text.
public struct StorybookSettingsSection: View {
    private let availability: StorybookAvailability

    public init(_ availability: StorybookAvailability) {
        self.availability = availability
    }

    private var configuration: StorybookConfiguration { availability.configuration }

    public var body: some View {
        Section {
            versionRow
        }
        // The catalog row waits on the gate's answer, asked here since an absent row can't.
        .task { await availability.resolve() }
        if availability.isEnabled { storybookSection }
    }

    @ViewBuilder private var versionRow: some View {
        if availability.isBuildAllowed {
            Button {
                availability.tapsVersion()
            } label: {
                versionContent.foregroundStyle(Color.primary)
            }
            .accessibilityLabel(configuration.labels.version)
            .accessibilityValue(configuration.version)
            .accessibilityIdentifier(configuration.identifiers.versionRow)
        } else {
            versionContent
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(configuration.labels.version)
                .accessibilityValue(configuration.version)
                .accessibilityIdentifier(configuration.identifiers.versionRow)
        }
    }

    private var versionContent: some View {
        LabeledContent(configuration.labels.version, value: configuration.version)
    }

    private var storybookSection: some View {
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
