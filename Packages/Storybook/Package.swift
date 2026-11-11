// swift-tools-version: 6.3
// StorybookSandbox is a product of its own, so only an app choosing that gate links StoreKit.
import PackageDescription

let package = Package(
    name: "StorybookPackage",
    defaultLocalization: "en",
    // The may-* apps' deployment targets.
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "Storybook", targets: ["Storybook"]),
        .library(name: "StorybookSandbox", targets: ["StorybookSandbox"])
    ],
    dependencies: [
        .package(url: "https://github.com/eure/swift-storybook", from: "3.3.0"),
        // Test target only: requirement tests drive a rendered screen as a person would.
        .package(url: "https://github.com/may-journal/apple-ui-testing-library", from: "1.7.2")
    ],
    targets: [
        .target(
            name: "Storybook",
            dependencies: [.product(name: "StorybookKit", package: "swift-storybook")],
            resources: [.process("Resources")]
        ),
        .target(name: "StorybookSandbox", dependencies: ["Storybook"]),
        .testTarget(
            name: "StorybookTests",
            dependencies: [
                "Storybook",
                "StorybookSandbox",
                .product(name: "StorybookKit", package: "swift-storybook"),
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
