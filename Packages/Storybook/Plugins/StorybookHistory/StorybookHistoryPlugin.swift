// cspell:ignore gitdir worktree
import Foundation
import PackagePlugin

/// Bundles `storybook-history.json` into the target it is applied to, from the git history of
/// the repo's requirement docs. It reruns when a commit, a checkout or a doc changes.
@main
struct StorybookHistoryPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        [try command(tool: context.tool(named: "storybook-history"), folder: context.package.directoryURL,
                     work: context.pluginWorkDirectoryURL)]
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension StorybookHistoryPlugin: XcodeBuildToolPlugin {
        func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
            [try command(tool: context.tool(named: "storybook-history"), folder: context.xcodeProject.directoryURL,
                         work: context.pluginWorkDirectoryURL)]
        }
    }
#endif

/// The build command that writes the history, with the files whose change makes it stale.
private func command(tool: PluginContext.Tool, folder: URL, work: URL) -> Command {
    let output = work.appending(path: "storybook-history.json")
    return .buildCommand(
        displayName: "Reading Storybook history",
        executable: tool.url,
        arguments: [folder.path(percentEncoded: false), output.path(percentEncoded: false)],
        inputFiles: staleWhen(folder),
        outputFiles: [output])
}

/// The files a new commit or checkout touches, and the requirement docs, found from `folder`
/// up to the repo's root. A worktree's `.git` file names its own git folder.
private func staleWhen(_ folder: URL) -> [URL] {
    let files = FileManager.default
    var root = folder
    while root.path != "/" {
        let dotGit = root.appending(path: ".git")
        var isFolder: ObjCBool = false
        if files.fileExists(atPath: dotGit.path, isDirectory: &isFolder) {
            let gitFolder = isFolder.boolValue ? dotGit : worktreeGitFolder(dotGit) ?? dotGit
            let docs = root.appending(path: "docs/requirements")
            let names = (try? files.contentsOfDirectory(atPath: docs.path)) ?? []
            return [gitFolder.appending(path: "HEAD"), gitFolder.appending(path: "logs/HEAD")]
                + names.filter { $0.hasSuffix(".md") }.map { docs.appending(path: $0) }
        }
        root.deleteLastPathComponent()
    }
    return []
}

/// The folder a worktree's `.git` file points at with its `gitdir:` line.
private func worktreeGitFolder(_ file: URL) -> URL? {
    guard let text = try? String(contentsOf: file, encoding: .utf8),
        let line = text.split(separator: "\n").first(where: { $0.hasPrefix("gitdir: ") })
    else { return nil }
    let path = String(line.dropFirst("gitdir: ".count))
    return path.hasPrefix("/") ? URL(filePath: path) : file.deletingLastPathComponent().appending(path: path)
}
