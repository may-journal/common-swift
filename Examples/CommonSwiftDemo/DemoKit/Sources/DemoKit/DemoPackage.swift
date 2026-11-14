/// A package under `Packages/` that the demo shows, in the sidebar's order.
public enum DemoPackage: String, CaseIterable, Identifiable, Hashable, Sendable {
    case adaptiveShell = "AdaptiveShell"
    case storybook = "Storybook"

    public var id: String { rawValue }

    /// The package `--demo-package <name>` names among the launch arguments, if any.
    public init?(arguments: [String]) {
        guard let flag = arguments.firstIndex(of: "--demo-package"), flag + 1 < arguments.count
        else { return nil }
        self.init(rawValue: arguments[flag + 1])
    }

    /// The package's name, as its folder and product spell it.
    public var name: String { rawValue }

    /// One line on what the package gives an app.
    public var summary: String {
        switch self {
        case .adaptiveShell: DemoWords.adaptiveShellSummary
        case .storybook: DemoWords.storybookSummary
        }
    }
}

/// A page the demo routes to by value.
public enum DemoPage: Hashable, Sendable {
    case settings
}
