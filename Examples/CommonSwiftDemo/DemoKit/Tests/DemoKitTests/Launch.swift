@testable import DemoKit
import Foundation
import Storybook
import SwiftUI
import UITestingLibrary

/// One launch of the demo, a Debug build, at a screen size: its screen and the person using it.
@MainActor
struct Launch {
    let screen: Screen
    let user: User

    /// The user defaults suite the Storybook switch lives in, emptied by each launch.
    static let suite = "demo.tests"

    init(_ size: ScreenSize) throws {
        UserDefaults.standard.removePersistentDomain(forName: Self.suite)
        let storybook = StorybookAvailability(
            gate: .debugOnly, configuration: DemoStorybook.configuration(arguments: []),
            defaults: UserDefaults(suiteName: Self.suite) ?? .standard)
        screen = try Screen.render(size: size) {
            DemoRoot(storybook: storybook)
                #if os(macOS)
                    // The library sets the size class on iOS only. A Mac test window gets the
                    // size class of the phone or iPad it stands for.
                    .environment(\.horizontalSizeClass, size.isRegularWidth ? .regular : .compact)
                #endif
        }
        user = User(screen)
    }

    /// Picks a package from the list.
    func picks(_ package: DemoPackage) async throws {
        try await user.taps(.identifier(package.rowIdentifier))
    }

    /// Opens Settings from the Storybook package, then the Storybook row.
    func opensStorybook() async throws {
        try await picks(.storybook)
        try await user.taps(.button(DemoWords.openSettings))
        // The sidebar still lists the Storybook package, so the row is found by its identifier.
        try await user.taps(.identifier(StorybookIdentifiers().storybookRow))
        try await user.sees(.identifier("storybook.close"))
    }

    /// The folder names under the repo's Packages/, one per package.
    static func packageFolders(from file: String = #filePath) -> Set<String> {
        var root = URL(fileURLWithPath: file)
        for _ in 0..<6 { root.deleteLastPathComponent() }
        let names = (try? FileManager.default.contentsOfDirectory(atPath: root.appending(path: "Packages").path)) ?? []
        return Set(names.filter { !$0.hasPrefix(".") })
    }

    func quits() throws {
        try screen.close()
        UserDefaults.standard.removePersistentDomain(forName: Self.suite)
    }
}
