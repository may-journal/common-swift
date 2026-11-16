#if os(macOS)
    import Foundation

    /// The repo's Swift files that only build the Storybook catalog, which the coverage map leaves out.
    /// The rule and why it holds are in the package README's Catalog files section.
    public struct StorybookCatalogFiles: Sendable {
        /// The catalog's repo-relative paths the rule finds.
        public let paths: Set<String>
        /// Repo-relative folders or files the maintainer leaves out, for a layout the rule misses.
        public let excluded: [String]
        /// The excluded paths that name no tracked file, such as one spelled from another folder.
        public let unmatched: [String]

        /// Reads the tracked files in `repo`'s working tree.
        public init(in repo: URL, excluding excluded: [String] = []) {
            func files(_ arguments: [String]) -> Set<String> {
                Set((StorybookHistoryReader.git(arguments, in: repo) ?? "").split(separator: "\n").map(String.init))
            }
            let swift = ["--", "*.swift"]
            let catalog = files(["grep", "-l", "-E", Self.importsStorybook] + swift)
                .intersection(files(["grep", "-l", "-w", "-e", "BookPage", "-e", "StorybookConfiguration"] + swift))
                .subtracting(files(["grep", "-l", "-E", Self.declaresScreen] + swift))
            let tracked = files(["ls-files"])
            var paths = catalog
            let folders = Dictionary(grouping: tracked.filter { $0.hasSuffix(".swift") }) {
                $0.split(separator: "/").dropLast()
            }
            for folder in folders.values where folder.filter(catalog.contains).count * 2 > folder.count {
                paths.formUnion(folder)
            }
            self.paths = paths
            let excluded = excluded.map { path in
                var path = path.hasPrefix("./") ? String(path.dropFirst(2)) : path
                while path.hasSuffix("/") { path.removeLast() }
                return path
            }
            self.excluded = excluded
            unmatched = excluded.filter { path in !tracked.contains { Self.path($0, isUnder: path) } }
        }

        /// A line importing the `Storybook` module, perhaps with attributes or a trailing comment.
        static let importsStorybook =
            #"^[[:space:]]*(@[_A-Za-z]+(\([^)]*\))?[[:space:]]+)*import[[:space:]]+Storybook[[:space:]]*(//.*)?$"#

        /// A line declaring a view, app or scene type, which makes its file a screen even if it holds a page.
        static let declaresScreen =
            #"(struct|class)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*(<.*>)?[[:space:]]*:"#
            + #"[^{]*[^A-Za-z0-9_](View|App|Scene)([^A-Za-z0-9_]|$)"#

        /// Whether the coverage map leaves out the repo file at `path`.
        public func contains(_ path: String) -> Bool {
            paths.contains(path) || excluded.contains { Self.path(path, isUnder: $0) }
        }

        /// Whether `path` is `excluded` itself or inside it, never a longer name that only starts the same.
        private static func path(_ path: String, isUnder excluded: String) -> Bool {
            path == excluded || path.hasPrefix(excluded + "/")
        }
    }
#endif
