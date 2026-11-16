import Storybook
import StorybookKit
import SwiftUI

/// The release acceptances, listed under this file's name. A release has no screen, so each
/// page shows its acceptance's card.
enum ReleasePage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0001.1 Release Please") { StorybookAcceptanceCard("0001.1") },
            BookPage(title: "0002.1 Version file") { StorybookAcceptanceCard("0002.1") },
            BookPage(title: "0002.2 Changelog and tag") { StorybookAcceptanceCard("0002.2") },
            BookPage(title: "0002.3 Read-only workflows") { StorybookAcceptanceCard("0002.3") }
        ]
    }
}
