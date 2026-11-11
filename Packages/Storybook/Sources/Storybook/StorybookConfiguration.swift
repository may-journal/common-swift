import Foundation
import StorybookKit

/// What a host app tells the package: its Settings words and accessibility identifiers, its
/// version, its own catalog pages and the launch arguments. Every field has a default, so
/// `StorybookConfiguration()` is enough.
public struct StorybookConfiguration {
    /// The Settings section's words; each defaults to the package's String Catalog.
    public var labels: StorybookLabels
    /// The Settings rows' accessibility identifiers.
    public var identifiers: StorybookIdentifiers
    /// The version row's value, such as "1.0.0 (42)".
    public var version: String
    /// Pages the app writes by hand, beside every `#Preview` the catalog finds. A title such
    /// as "DiaryCard: empty" puts the page under DiaryCard, as a preview's name does.
    public var pages: @MainActor () -> [BookPage]
    /// The process arguments: `--storybook` and the `--storybook-*` settings.
    public var arguments: [String]

    public init(
        labels: StorybookLabels = StorybookLabels(),
        identifiers: StorybookIdentifiers = StorybookIdentifiers(),
        version: String = StorybookConfiguration.bundleVersion(),
        pages: @escaping @MainActor () -> [BookPage] = { [] },
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) {
        self.labels = labels
        self.identifiers = identifiers
        self.version = version
        self.pages = pages
        self.arguments = arguments
    }

    /// "1.0.0 (42)": the marketing version, then the build number.
    public static func bundleVersion(_ bundle: Bundle = .main) -> String {
        let info = bundle.infoDictionary
        let marketing = info?["CFBundleShortVersionString"] as? String ?? ""
        let build = info?["CFBundleVersion"] as? String ?? ""
        return "\(marketing) (\(build))"
    }
}

/// The Settings section's words. A host passes its own to match its String Catalog.
public struct StorybookLabels: Sendable {
    /// The version row's name.
    public var version: String
    /// The row that opens the catalog.
    public var storybook: String
    /// The footer under that row.
    public var footer: String

    public init(
        version: String = StorybookWords.version,
        storybook: String = StorybookWords.name,
        footer: String = StorybookWords.footer
    ) {
        self.version = version
        self.storybook = storybook
        self.footer = footer
    }
}

/// The Settings rows' accessibility identifiers, for the host's own tests.
public struct StorybookIdentifiers: Sendable {
    public var versionRow: String
    public var storybookRow: String

    public init(versionRow: String = "settings.version", storybookRow: String = "settings.storybook") {
        self.versionRow = versionRow
        self.storybookRow = storybookRow
    }
}
