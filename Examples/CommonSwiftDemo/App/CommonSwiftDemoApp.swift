import DemoKit
import SwiftUI

/// Shows every common-swift package at work. Launch with `--storybook "<page name>"` to open one
/// Storybook page straight away.
@main
struct CommonSwiftDemoApp: App {
    @State private var storybook = DemoStorybook.availability()

    var body: some Scene {
        WindowGroup {
            DemoRoot(storybook: storybook)
        }
    }
}
