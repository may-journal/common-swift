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

    /// A page per package, showing a piece of it on its own, then a page for every other
    /// acceptance. Each page sits in a file named after what it shows, which the catalog lists
    /// it under.
    @MainActor
    public static var pages: [BookPage] {
        [packagesPage] + StorybookBadgePage.pages + DemoRootPage.pages
            + ShellPage.pages + ShellRowPage.pages + LinksPage.pages + FamilyDayPage.pages
            + StorybookSettingsPage.pages + StorybookHistoryPage.pages + StorybookCoveragePage.pages
            + ReleasePage.pages + ChecksPage.pages + ManifestPage.pages
    }

    /// One page with a labeled row for each package.
    @MainActor
    static var packagesPage: BookPage {
        BookPage(title: "0012.4 Packages") {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(DemoPackage.allCases) { package in
                    LabeledSample(label: "\(package.name): \(sample(of: package))") { packageSample(package) }
                }
            }
            .padding()
        }
    }

    @MainActor @ViewBuilder
    private static func packageSample(_ package: DemoPackage) -> some View {
        switch package {
        case .adaptiveShell: AdaptiveShellPage.sample
        case .familyDay: FamilyDayPage.sample
        case .storybook: StorybookPage.sample
        }
    }

    /// The piece of the package its page shows, which its page's name ends with.
    public static func sample(of package: DemoPackage) -> String {
        switch package {
        case .adaptiveShell: "Empty pane"
        case .familyDay: "Saturday's rows"
        case .storybook: "Data length"
        }
    }

    /// The Storybook availability the demo app holds, so the app links DemoKit alone.
    @MainActor
    public static func availability() -> StorybookAvailability {
        StorybookAvailability(gate: .debugOnly, configuration: configuration())
    }
}

/// A sample under a small label, one row of a page that draws every variant of an acceptance.
struct LabeledSample<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: label).font(.caption).foregroundStyle(.secondary)
            content
        }
    }
}
