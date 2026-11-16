import Foundation
import PackagePlugin

/// Writes `docs/requirements/coverage.json` at the repo's root, mapping each requirement
/// acceptance to the source files its test covers, by running each requirement test alone.
/// Arguments pass through to the tool, such as `--scheme` and `--destination` for an Xcode project.
@main
struct StorybookCoveragePlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        try generate(tool: context.tool(named: "storybook-coverage"), folder: context.package.directoryURL,
                     arguments: arguments)
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension StorybookCoveragePlugin: XcodeCommandPlugin {
        func performCommand(context: XcodePluginContext, arguments: [String]) throws {
            try generate(tool: context.tool(named: "storybook-coverage"), folder: context.xcodeProject.directoryURL,
                         arguments: arguments)
        }
    }
#endif

/// Runs the tool for the repo holding `folder` and fails the command when it fails.
private func generate(tool: PluginContext.Tool, folder: URL, arguments: [String]) throws {
    let process = Process()
    process.executableURL = tool.url
    process.arguments = ["--root", folder.path(percentEncoded: false)] + arguments
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        throw StorybookCoverageFailure(status: process.terminationStatus)
    }
}

/// The tool's exit status when it could not write the map.
private struct StorybookCoverageFailure: Error, CustomStringConvertible {
    let status: Int32

    var description: String { "storybook-coverage exited with status \(status)" }
}
