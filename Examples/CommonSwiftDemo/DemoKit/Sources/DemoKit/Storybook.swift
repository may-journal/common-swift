import Storybook
import StorybookKit
import SwiftUI

/// Storybook's sample for the packages page: a sample the header's data length steps.
enum StorybookPage {
    @MainActor @ViewBuilder static var sample: some View {
        PreviewSample { length in
            Text(length.pick(
                empty: DemoWords.prompt, short: DemoPackage.storybook.name,
                long: DemoWords.storybookSummary))
        }
    }
}
