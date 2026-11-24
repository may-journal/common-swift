// swift-tools-version: 6.3
// The day every may-* app keys its part of a day by, the row it writes and the links that open it.
import PackageDescription

let package = Package(
    name: "FamilyDayPackage",
    defaultLocalization: "en",
    // The may-* apps' deployment targets.
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "FamilyDay", targets: ["FamilyDay"])
    ],
    dependencies: [
        // A day link opens through AdaptiveShell's PendingOpen.
        .package(path: "../AdaptiveShell"),
        // Test target only: requirement tests drive a rendered screen as a person would.
        .package(url: "https://github.com/may-journal/apple-ui-testing-library", from: "1.7.2"),
        // Test target only: lets the coverage tool map every test from one run.
        .package(path: "../Storybook")
    ],
    targets: [
        .target(
            name: "FamilyDay",
            dependencies: [.product(name: "AdaptiveShell", package: "AdaptiveShell")],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FamilyDayTests",
            dependencies: [
                "FamilyDay",
                .product(name: "AdaptiveShell", package: "AdaptiveShell"),
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library"),
                .product(name: "StorybookCoverageScope", package: "Storybook")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
