import AdaptiveShell
import StorybookKit
import SwiftUI

/// AdaptiveShell's sample for the packages page: a pane with nothing picked, showing its prompt.
enum AdaptiveShellPage {
    @MainActor @ViewBuilder static var sample: some View {
        ShellPane(selection: String?.none) { Text(verbatim: $0) } empty: {
            Text(DemoWords.prompt)
        }
    }
}
