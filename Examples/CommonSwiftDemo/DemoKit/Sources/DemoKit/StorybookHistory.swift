import Storybook
import StorybookKit
import SwiftUI

/// The StorybookHistory tool's pages, listed under this file's name. The tool runs at build
/// time with no screen, so each page shows its acceptance's card.
enum StorybookHistoryPage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0015.6 Renamed and rebased") { StorybookAcceptanceCard("0015.6") },
            BookPage(title: "0015.7 Shallow clone") { StorybookAcceptanceCard("0015.7") }
        ]
    }
}
