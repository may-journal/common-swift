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
        DemoPackage.allCases.map { package in
            BookPage(title: title(of: package)) {
                switch package {
                case .adaptiveShell:
                    ShellPane(selection: String?.none) { Text(verbatim: $0) } empty: {
                        Text(DemoWords.prompt)
                    }
                case .storybook:
                    PreviewSample { length in
                        Text(length.pick(
                            empty: DemoWords.prompt, short: DemoPackage.storybook.name,
                            long: DemoWords.storybookSummary))
                    }
                }
            }
        }
    }

    /// A package's page name in the catalog: the package, then the piece it shows.
    public static func title(of package: DemoPackage) -> String {
        "\(package.name): \(sample(of: package))"
    }

    /// The piece of the package its page shows, which the catalog lists under the package.
    public static func sample(of package: DemoPackage) -> String {
        switch package {
        case .adaptiveShell: "Empty pane"
        case .storybook: "Data length"
        }
    }

    /// The Storybook availability the demo app holds, so the app links DemoKit alone.
    @MainActor
    public static func availability() -> StorybookAvailability {
        StorybookAvailability(gate: .debugOnly, configuration: configuration())
    }
}
