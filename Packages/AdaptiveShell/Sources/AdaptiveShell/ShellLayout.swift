import SwiftUI

/// How the shell lays out the screen it has.
public enum ShellLayout: Sendable, Hashable {
    /// One stack: pages push over the sidebar's content, as on a phone.
    case stack
    /// The sidebar beside a pane, where pages open, as on an iPad or the Mac.
    case split

    /// The layout for a screen of `sizeClass`: a compact width stacks. A Mac window has no size
    /// class, so it splits.
    public static func fitting(_ sizeClass: UserInterfaceSizeClass?) -> ShellLayout {
        sizeClass == .compact ? .stack : .split
    }
}

extension EnvironmentValues {
    /// The layout of the shell around this view; `.stack` outside any shell.
    @Entry public var shellLayout: ShellLayout = .stack
}
