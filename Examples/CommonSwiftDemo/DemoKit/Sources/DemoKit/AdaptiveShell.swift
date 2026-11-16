import AdaptiveShell
import StorybookKit
import SwiftUI

/// AdaptiveShell's catalog page, which this file's name lists it under: a pane with nothing
/// picked, showing its prompt.
enum AdaptiveShellPage {
    @MainActor static var page: BookPage {
        BookPage(title: "0012.4 Empty pane") {
            ShellPane(selection: String?.none) { Text(verbatim: $0) } empty: {
                Text(DemoWords.prompt)
            }
        }
    }
}
