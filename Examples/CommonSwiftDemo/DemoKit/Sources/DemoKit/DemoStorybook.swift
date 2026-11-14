import AdaptiveShell
import Storybook
import StorybookKit
import SwiftUI

/// The demo's Storybook catalog: one page per package, listed under the package's name.
public enum DemoStorybook {
    /// The configuration the demo's availability takes, with the launch's arguments.
    @MainActor
    public static func configuration(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> StorybookConfiguration {
        StorybookConfiguration(pages: { pages }, arguments: arguments)
    }

    /// A page per package, showing a piece of it on its own.
    @MainActor
    public static var pages: [BookPage] {
        [
            BookPage(title: "AdaptiveShell: \(paneSample)") {
                ShellPane(selection: String?.none) { Text(verbatim: $0) } empty: {
                    Text(DemoWords.prompt)
                }
            },
            BookPage(title: "Storybook: \(lengthSample)") {
                PreviewSample { length in
                    Text(length.pick(empty: DemoWords.prompt, short: "Kites", long: DemoWords.storybookSummary))
                }
            }
        ]
    }

    /// The AdaptiveShell page's name in the catalog.
    public static let paneSample = "empty pane"
    /// The Storybook page's name in the catalog.
    public static let lengthSample = "data length"
}
