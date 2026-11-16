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
        .library(name: "AdaptiveShell", targets: ["AdaptiveShell"]),
        .library(name: "Storybook", targets: ["Storybook"]),
        .library(name: "StorybookSandbox", targets: ["StorybookSandbox"]),
        // A host applies it to its app target, so the catalog badges new and changed pages.
        .plugin(name: "StorybookHistory", targets: ["StorybookHistory"]),
        // A host runs it before a build that needs real badge ages; the coverage map it writes stays untracked.
        .plugin(name: "StorybookCoverage", targets: ["StorybookCoverage"])
    ],
    dependencies: [
        .package(url: "https://github.com/eure/swift-storybook", from: "3.3.0")
    ],
    targets: [
        .target(
            name: "AdaptiveShell",
            path: "Packages/AdaptiveShell/Sources/AdaptiveShell",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Storybook",
            dependencies: [
                "StorybookHistoryKit",
                .product(name: "StorybookKit", package: "swift-storybook")
            ],
            path: "Packages/Storybook/Sources/Storybook",
            resources: [.process("Resources")]
        ),
        .target(name: "StorybookHistoryKit", path: "Packages/Storybook/Sources/StorybookHistoryKit"),
        .executableTarget(
            name: "storybook-history",
            dependencies: ["StorybookHistoryKit"],
            path: "Packages/Storybook/Sources/storybook-history"
        ),
        .plugin(
            name: "StorybookHistory",
            capability: .buildTool(),
            dependencies: ["storybook-history"],
            path: "Packages/Storybook/Plugins/StorybookHistory"
        ),
        .executableTarget(
            name: "storybook-coverage",
            dependencies: ["StorybookHistoryKit"],
            path: "Packages/Storybook/Sources/storybook-coverage"
        ),
        .plugin(
            name: "StorybookCoverage",
            capability: .command(
                intent: .custom(
                    verb: "storybook-coverage",
                    description: "Map each requirement acceptance to the files its test covers"),
                permissions: [
                    .writeToPackageDirectory(reason: "Writes docs/requirements/coverage.json")
                ]),
            dependencies: ["storybook-coverage"],
            path: "Packages/Storybook/Plugins/StorybookCoverage"
        ),
        .target(
            name: "StorybookSandbox",
            dependencies: ["Storybook"],
            path: "Packages/Storybook/Sources/StorybookSandbox"
        )
    ],
    swiftLanguageModes: [.v6]
)
