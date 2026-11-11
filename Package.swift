// swift-tools-version: 6.3
// An app depends on this repo by URL, and SwiftPM reads only this root manifest. It lists each
// package's products by path; each folder under Packages/ keeps its own manifest and tests.
import PackageDescription

let package = Package(
    name: "common-swift",
    defaultLocalization: "en",
    // The may-* apps' deployment targets.
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "Storybook", targets: ["Storybook"]),
        .library(name: "StorybookSandbox", targets: ["StorybookSandbox"])
    ],
    dependencies: [
        .package(url: "https://github.com/eure/swift-storybook", from: "3.3.0")
    ],
    targets: [
        .target(
            name: "Storybook",
            dependencies: [.product(name: "StorybookKit", package: "swift-storybook")],
            path: "Packages/Storybook/Sources/Storybook",
            resources: [.process("Resources")]
        ),
        .target(
            name: "StorybookSandbox",
            dependencies: ["Storybook"],
            path: "Packages/Storybook/Sources/StorybookSandbox"
        )
    ],
    swiftLanguageModes: [.v6]
)
