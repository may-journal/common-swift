// swift-tools-version: 6.0
// One library product per package, each its own target, so an app links only what it imports.
// Platforms match the may-* apps' deployment targets (project.yml, SWIFT_VERSION 6.0).
import PackageDescription

let package = Package(
    name: "common-swift",
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "Navigation", targets: ["Navigation"]),
        .library(name: "Theme", targets: ["Theme"]),
        .library(name: "ScreenStates", targets: ["ScreenStates"]),
        .library(name: "AdaptiveLayout", targets: ["AdaptiveLayout"]),
    ],
    dependencies: [
        // Test targets only: requirement tests drive a rendered screen as a person would.
        .package(url: "https://github.com/may-journal/apple-ui-testing-library", from: "1.7.2")
    ],
    targets: [
        .target(name: "Navigation"),
        .testTarget(
            name: "NavigationTests",
            dependencies: [
                "Navigation",
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library"),
            ]
        ),
        .target(name: "Theme"),
        .testTarget(
            name: "ThemeTests",
            dependencies: [
                "Theme",
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library"),
            ]
        ),
        // Draws in the app's theme, so it links Theme and nothing else.
        .target(name: "ScreenStates", dependencies: ["Theme"]),
        .testTarget(
            name: "ScreenStatesTests",
            dependencies: [
                "ScreenStates",
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library"),
            ]
        ),
        // Sizes its margins, gaps and cards from the app's theme, so it links Theme alone.
        .target(name: "AdaptiveLayout", dependencies: ["Theme"]),
        .testTarget(
            name: "AdaptiveLayoutTests",
            dependencies: [
                "AdaptiveLayout",
                "Theme",
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
