// swift-tools-version: 6.3
// The shell an app draws its sidebar, pane and pages in, on a phone, a wide screen and the Mac.
import PackageDescription

let package = Package(
    name: "AdaptiveShellPackage",
    defaultLocalization: "en",
    // The may-* apps' deployment targets.
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "AdaptiveShell", targets: ["AdaptiveShell"])
    ],
    dependencies: [
        // Test target only: requirement tests drive a rendered screen as a person would.
        .package(url: "https://github.com/may-journal/apple-ui-testing-library", from: "1.7.2")
    ],
    targets: [
        .target(name: "AdaptiveShell", resources: [.process("Resources")]),
        .testTarget(
            name: "AdaptiveShellTests",
            dependencies: [
                "AdaptiveShell",
                .product(name: "UITestingLibrary", package: "apple-ui-testing-library")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
