import Storybook
import StorybookKit
import SwiftUI

/// Depending on common-swift, listed under their requirements. A package manifest has no
/// screen, so each page shows its acceptance's card.
enum ManifestPage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0009.1 Version tag") { StorybookAcceptanceCard("0009.1") },
            BookPage(title: "0009.2 No StoreKit") { StorybookAcceptanceCard("0009.2") }
        ]
    }
}
