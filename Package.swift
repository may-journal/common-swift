// swift-tools-version: 6.0
// One library product per package, each its own target, so an app links only what it imports.
// Platforms match the may-* apps' deployment targets (project.yml, SWIFT_VERSION 6.0).
import PackageDescription

let package = Package(
    name: "common-swift",
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "Navigation", targets: ["Navigation"])
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
    ],
    swiftLanguageModes: [.v6]
)
