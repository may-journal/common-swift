import AdaptiveShell
import StorybookKit
import SwiftUI

/// AdaptiveShell's toggling sidebar rows, listed under their requirements. Each page opens a
/// shell in the state its acceptance starts from; tap the row or Back to see what follows.
enum ShellRowPage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0014.1 Settings open") { ShellSample(.split, path: [.settings]) },
            BookPage(title: "0014.2 Page above Settings") {
                ShellSample(.split, path: [.settings, .package(.storybook)])
            },
            BookPage(title: "0014.3 Another page open") {
                ShellSample(.split, path: [.package(.storybook)])
            },
            BookPage(title: "0014.4 Entry picked") { ShellSample(.split, picked: .adaptiveShell) },
            BookPage(title: "0014.5 Settings row marked") { ShellSample(.split, path: [.settings]) },
            BookPage(title: "0014.6 Entry row marked") { ShellSample(.split, picked: .storybook) },
            BookPage(title: "0014.7 Back on a phone") { ShellSample(.stack, path: [.settings]) },
            BookPage(title: "0014.8 Back with the sidebar hidden") {
                ShellSample(.split, configuration: .hiding, path: [.settings])
            }
        ]
    }
}
