import Foundation
import Storybook
import StorybookKit
import StorybookSandbox
import SwiftUI
import UITestingLibrary

/// The build a person installs. The App Store's answer is replayed, never asked live.
enum Build {
    case appStore, testFlight, debug

    var gate: StorybookGate {
        switch self {
        case .appStore: .debugOrSandbox(isDebug: false) { .production }
        case .testFlight: .debugOrSandbox(isDebug: false) { .sandbox }
        case .debug: .debugOrSandbox(isDebug: true) { .xcode }
        }
    }
}

/// A small diary app that adopts the package as an app maintainer does. It has the Settings
/// section in its Form, the entry at its root and one page of its own.
struct DiaryApp: View {
    let storybook: StorybookAvailability
    /// Whether the app keeps a Version row of its own and adds only the Storybook row.
    var ownsVersion = false

    var body: some View {
        Form {
            if ownsVersion {
                Section { LabeledContent(StorybookWords.version, value: storybook.configuration.version) }
                StorybookRowSection(storybook)
            } else {
                StorybookSettingsSection(storybook)
            }
        }
        .formStyle(.grouped)
        .task { await storybook.resolve() }
        .storybookEntry(storybook)
    }

    /// The app's diary card, showing the sample the header's data length picks. StorybookKit's
    /// demo `#Preview` is replayed, since a test bundle's catalog finds no previews.
    static var pages: [BookPage] {
        [
            BookPage(title: "DiaryCard: sample") {
                PreviewSample { length in
                    Text(length.pick(empty: emptySample, short: shortSample, long: longSample))
                }
            },
            BookPage("StorybookKit/\(demoComponent).swift", 593, title: "line: 593") {
                Color.purple
            }
        ]
    }

    /// The file StorybookKit's unnamed demo preview sits in, which would name its component.
    static let demoComponent = "StorybookDisplayRootView"

    static let emptySample = "No entries yet"
    static let shortSample = "Kites"
    static let longSample = "Kites over the dunes at dawn, and tea after"
}

/// One launch of the diary app: its rendered screen and the person using it.
@MainActor
struct Launch {
    let storybook: StorybookAvailability
    let screen: Screen
    let user: User

    /// The one user defaults suite the tests keep the hidden switch in. The suite runs one test
    /// at a time, so each fresh launch empties it and none sees another's switch.
    static let suite = "storybook.tests"

    /// Opens the app; a relaunch keeps the switch the launch before turned on.
    init(
        _ build: Build, arguments: [String] = [], relaunch: Bool = false, ownsVersion: Bool = false
    ) throws {
        if !relaunch { Self.forgetsSettings() }
        let configuration = StorybookConfiguration(
            version: "1.0 (7)", pages: { DiaryApp.pages }, arguments: arguments)
        storybook = StorybookAvailability(
            gate: build.gate, configuration: configuration,
            defaults: UserDefaults(suiteName: Self.suite) ?? .standard)
        let storybook = storybook
        screen = try Screen.render { DiaryApp(storybook: storybook, ownsVersion: ownsVersion) }
        user = User(screen)
    }

    /// Closes the app for good and empties the suite.
    func quits() throws {
        try screen.close()
        Self.forgetsSettings()
    }

    private static func forgetsSettings() {
        UserDefaults.standard.removePersistentDomain(forName: suite)
    }

    /// Waits until the gate's answer turns the version row into a button.
    func waitsForTheAnswer() async throws {
        try await user.sees(.button(StorybookWords.version))
    }

    /// Taps the version row seven times, as a tester does to unlock the catalog.
    func tapsVersionSevenTimes() async throws {
        for _ in 0..<StorybookAvailability.unlockTaps {
            try await user.taps(.button(StorybookWords.version))
        }
    }

    /// Opens the catalog from its Settings row.
    func opensStorybook() async throws {
        try await user.taps(.button(StorybookWords.name))
        try await user.sees(.identifier("storybook.close"))
    }
}
