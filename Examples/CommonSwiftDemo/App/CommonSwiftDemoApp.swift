import DemoKit
import Storybook
import SwiftUI

/// Shows every common-swift package at work. Launch with `--storybook "<page name>"` to open one
/// Storybook page straight away.
@main
struct CommonSwiftDemoApp: App {
    @State private var storybook = StorybookAvailability(
        gate: .debugOnly, configuration: DemoStorybook.configuration())

    var body: some Scene {
        WindowGroup {
            DemoRoot(storybook: storybook)
        }
    }
}
