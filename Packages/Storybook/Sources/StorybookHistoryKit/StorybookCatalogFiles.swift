#if os(macOS)
    import Foundation

    /// The repo's Swift files that only build the Storybook catalog, which the coverage map leaves out.
    /// The rule and why it holds are in the package README's Catalog files section.
    public struct StorybookCatalogFiles: Sendable {
        /// The catalog's repo-relative paths the rule finds.
        public let paths: Set<String>
        /// Repo-relative folders or files the maintainer leaves out, for a layout the rule misses.
        public let excluded: [String]

        /// Reads the tracked Swift files in `repo`'s working tree.
        public init(in repo: URL, excluding excluded: [String] = []) {
            func files(_ arguments: [String]) -> [String] {
                (StorybookHistoryReader.git(arguments + ["--", "*.swift"], in: repo) ?? "")
                    .split(separator: "\n").map(String.init)
            }
            let importing = files(["grep", "-l", "-E", Self.importsStorybook])
            let catalog = Set(importing).intersection(
                files(["grep", "-l", "-w", "-e", "BookPage", "-e", "StorybookConfiguration"]))
            var paths = catalog
            for folder in Dictionary(grouping: files(["ls-files"]), by: { $0.split(separator: "/").dropLast() })
                .values where folder.filter(catalog.contains).count * 2 > folder.count {
                paths.formUnion(folder)
            }
            self.paths = paths
            self.excluded = excluded.map { path in
                var path = path.hasPrefix("./") ? String(path.dropFirst(2)) : path
                while path.hasSuffix("/") { path.removeLast() }
                return path
            }
        }

        /// A line importing the `Storybook` module, perhaps with attributes or a trailing comment.
        static let importsStorybook =
            #"^[[:space:]]*(@[_A-Za-z]+[[:space:]]+)*import[[:space:]]+Storybook[[:space:]]*(//.*)?$"#

        /// Whether the coverage map leaves out the repo file at `path`.
        public func contains(_ path: String) -> Bool {
            paths.contains(path) || excluded.contains { path == $0 || path.hasPrefix($0 + "/") }
        }
    }
#endif
