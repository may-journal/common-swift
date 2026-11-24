import Storybook
import StorybookKit
import SwiftUI

/// Storybook's catalog page, listed under its requirement: a sample the header's data
/// length steps.
enum StorybookPage {
    @MainActor static var page: BookPage {
        BookPage(title: "0012.4 Data length") {
            PreviewSample { length in
                Text(length.pick(
                    empty: DemoWords.prompt, short: DemoPackage.storybook.name,
                    long: DemoWords.storybookSummary))
            }
        }
    }
}
