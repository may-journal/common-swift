import Storybook
import StorybookKit
import SwiftUI

/// The pull request check, the commit hook and the requirements check, listed under their
/// requirements. Checks have no screen, so each page shows its acceptance's card.
enum ChecksPage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0003.1 Title") { StorybookAcceptanceCard("0003.1") },
            BookPage(title: "0003.2 Entry link") { StorybookAcceptanceCard("0003.2") },
            BookPage(title: "0003.3 Release pull request") { StorybookAcceptanceCard("0003.3") },
            BookPage(title: "0004.1 Commit subject") { StorybookAcceptanceCard("0004.1") },
            BookPage(title: "0004.2 Changelog entry") { StorybookAcceptanceCard("0004.2") },
            BookPage(title: "0004.3 Broken link in a commit") { StorybookAcceptanceCard("0004.3") },
            BookPage(title: "0004.4 Broken link in a pull request") {
                StorybookAcceptanceCard("0004.4")
            },
            BookPage(title: "0005.1 Missing test") { StorybookAcceptanceCard("0005.1") }
        ]
    }
}
