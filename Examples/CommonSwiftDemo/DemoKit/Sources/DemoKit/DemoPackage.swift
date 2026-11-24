/// A package under `Packages/` that the demo shows, in the sidebar's order.
public enum DemoPackage: String, CaseIterable, Identifiable, Hashable, Sendable {
    case adaptiveShell = "AdaptiveShell"
    case familyDay = "FamilyDay"
    case storybook = "Storybook"

    public var id: String { rawValue }

    /// The package's name, as its folder and product spell it.
    public var name: String { rawValue }

    /// The identifier of the package's row in the list.
    public var rowIdentifier: String { "package.\(rawValue)" }

    /// One line on what the package gives an app.
    public var summary: String {
        switch self {
        case .adaptiveShell: DemoWords.adaptiveShellSummary
        case .familyDay: DemoWords.familyDaySummary
        case .storybook: DemoWords.storybookSummary
        }
    }
}

/// A page the demo routes to by value.
public enum DemoPage: Hashable, Sendable {
    case package(DemoPackage)
    case settings
}
