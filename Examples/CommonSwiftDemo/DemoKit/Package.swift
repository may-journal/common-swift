// swift-tools-version: 6.3
// The demo's screens, in a library the app target and the requirement tests both link.
import PackageDescription

let package = Package(
    name: "CommonSwiftDemo",
    defaultLocalization: "en",
    // The may-* apps' deployment targets.
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "DemoKit", targets: ["DemoKit"])
    ],
    dependencies: [
        // This repo by path, so the demo always shows the packages as they are in the checkout.
        .package(name: "common-swift", path: "../../.."),
        .package(url: "https://github.com/eure/swift-storybook", from: "3.3.0"),
        // Test target only: requirement tests drive the rendered demo as a person would.
        .package(url: "https://github.com/may-journal/apple-ui-testing-library", from: "1.7.2")
    ],
    targets: [
        .target(
            name: "DemoKit",
            dependencies: [
                .product(name: "AdaptiveShell", package: "common-swift"),
                .product(name: "Storybook", package: "common-swift"),
                .product(name: "StorybookKit", package: "swift-storybook")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "DemoKitTests",
            dependencies: [
                "DemoKit",
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
