import Foundation

/// The package's own words, as entries of its String Catalog. A host passes its own through
/// `ShellConfiguration` to match its catalog.
public enum ShellWords {
    /// "Show Sidebar": the rail button while the sidebar is hidden.
    public static var showSidebar: String {
        String(
            localized: "action.showSidebar", defaultValue: "Show Sidebar", bundle: .module,
            comment: "Action: the rail button that brings back the hidden sidebar column")
    }

    /// "Hide Sidebar": the rail button while the sidebar shows.
    public static var hideSidebar: String {
        String(
            localized: "action.hideSidebar", defaultValue: "Hide Sidebar", bundle: .module,
            comment: "Action: the rail button that hides the sidebar column")
    }
}
