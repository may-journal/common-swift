import Storybook
import StorybookKit
import SwiftUI

/// The StorybookCoverage tool's pages, listed under this file's name. The tool maps a repo with no
/// screen, so each page shows its acceptance's card.
enum StorybookCoveragePage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0016.1 Catalog left out") { StorybookAcceptanceCard("0016.1") },
            BookPage(title: "0016.2 Excluded folder") { StorybookAcceptanceCard("0016.2") },
            BookPage(title: "0017.1 Current map kept") { StorybookAcceptanceCard("0017.1") },
            BookPage(title: "0017.2 Changed tree mapped") { StorybookAcceptanceCard("0017.2") },
            BookPage(title: "0017.3 Xcodebuild arguments") { StorybookAcceptanceCard("0017.3") }
        ]
    }
}
