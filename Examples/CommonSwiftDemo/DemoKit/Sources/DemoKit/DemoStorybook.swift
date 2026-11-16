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

    /// A page per package, showing a piece of it on its own. Each page sits in a file named
    /// after its package, which the catalog lists it under.
    @MainActor
    public static var pages: [BookPage] {
        DemoPackage.allCases.map(page)
    }

    @MainActor
    static func page(_ package: DemoPackage) -> BookPage {
        switch package {
        case .adaptiveShell: AdaptiveShellPage.page
        case .storybook: StorybookPage.page
        }
    }

    /// The piece of the package its page shows, which its page's name ends with.
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
