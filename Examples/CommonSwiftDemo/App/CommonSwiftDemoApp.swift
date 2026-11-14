import DemoKit
import SwiftUI

/// Shows every common-swift package at work. Launch with `--storybook "<page name>"` to open one
/// Storybook page straight away.
@main
struct CommonSwiftDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoWindow()
        }
    }
}
