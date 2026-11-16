import Storybook
import StorybookKit
import SwiftUI

/// Storybook's Settings rows and launch settings, listed under this file's name. Each Settings
/// page draws the real section for one kind of build, with a switch of its own.
enum StorybookSettingsPage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0006.1 App Store build") {
                SettingsSample("0006.1", gate: .appStore)
            },
            BookPage(title: "0006.2 TestFlight build") {
                SettingsSample("0006.2", gate: .testFlight)
            },
            BookPage(title: "0006.3 Seven taps") { SettingsSample("0006.3", gate: .testFlight) },
            BookPage(title: "0006.4 Unlocked before") {
                SettingsSample("0006.4", gate: .testFlight, unlockedBefore: true)
            },
            BookPage(title: "0006.5 Debug build") { SettingsSample("0006.5", gate: .debug) },
            BookPage(title: "0006.6 App's own Version row") {
                SettingsSample("0006.6", gate: .testFlight, ownVersionRow: true)
            },
            BookPage(title: "0007.1 Done") { SettingsSample("0007.1", gate: .debug) },
            BookPage(title: "0007.2 Mac shortcut") { StorybookAcceptanceCard("0007.2") },
            BookPage(title: "0007.3 Launch a page") { StorybookAcceptanceCard("0007.3") },
            BookPage(title: "0007.4 Listed by file") { StorybookAcceptanceCard("0007.4") },
            BookPage(title: "0008.1 Duo frame") {
                Text(verbatim: StorybookDevice.duo.label(StorybookDevice.duo.defaultOrientation))
                    .font(.body.monospacedDigit())
                    .padding()
            },
            BookPage(title: "0008.3 No freshness panel") { StorybookAcceptanceCard("0008.3") },
            BookPage(title: "0008.4 Freshness panel kept") { StorybookAcceptanceCard("0008.4") }
        ]
    }
}

private extension StorybookGate {
    /// An App Store build's answer: never.
    static var appStore: StorybookGate { StorybookGate(isDebug: false) { false } }
    /// A TestFlight build's answer: yes, once Version is tapped seven times.
    static var testFlight: StorybookGate { StorybookGate(isDebug: false) { true } }
    /// A Debug build, open with no taps.
    static var debug: StorybookGate { StorybookGate(isDebug: true) { true } }
}

/// A Settings form with Storybook's section, or an app's own Version row above the Storybook
/// row. Its switch lives in a defaults suite named for the page, emptied as the page opens.
private struct SettingsSample: View {
    @State private var availability: StorybookAvailability
    private let ownVersionRow: Bool

    init(_ id: String, gate: StorybookGate, unlockedBefore: Bool = false, ownVersionRow: Bool = false) {
        let suite = "demo.storybook.\(id)"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.removePersistentDomain(forName: suite)
        if unlockedBefore { defaults.set(true, forKey: StorybookAvailability.unlockKey) }
        _availability = State(initialValue: StorybookAvailability(
            gate: gate, configuration: StorybookConfiguration(arguments: []), defaults: defaults))
        self.ownVersionRow = ownVersionRow
    }

    var body: some View {
        Form {
            if ownVersionRow {
                Section {
                    Button(action: availability.tapsVersion) {
                        LabeledContent(
                            availability.configuration.labels.version,
                            value: availability.configuration.version)
                    }
                    .foregroundStyle(Color.primary)
                }
                StorybookRowSection(availability)
            } else {
                StorybookSettingsSection(availability)
            }
        }
        .formStyle(.grouped)
        .task { await availability.resolve() }
    }
}
