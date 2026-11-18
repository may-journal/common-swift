#if os(macOS)
    import Foundation

    /// The commit and arguments the coverage map was written for, kept in the checkout's git folder.
    /// The StorybookCoverage tool skips a run on a clean tree whose stamp matches.
    public struct StorybookCoverageStamp {
        /// The map the stamp vouches for.
        public let map: URL
        /// The stamp file, or nil outside a git repo.
        let file: URL?
        /// HEAD and the arguments, or nil on a dirty tree, whose map matches no commit.
        let state: String?

        /// Reads HEAD and the tree's state now, before the tool runs any test.
        public init(repo: URL, map: URL, arguments: [String]) {
            self.map = map
            file = StorybookHistoryReader.git(
                ["rev-parse", "--path-format=absolute", "--git-path", "storybook-coverage.commit"], in: repo
            ).map { URL(filePath: $0) }
            let head = StorybookHistoryReader.git(["rev-parse", "HEAD"], in: repo)
            // An untracked file counts as dirty, since a new test changes what the map lists.
            let clean = StorybookHistoryReader.git(["status", "--porcelain", "--untracked-files=all"], in: repo) == ""
            state = head.flatMap { clean ? ([$0] + arguments).joined(separator: "\n") + "\n" : nil }
        }

        /// True when the map exists and was written for this commit and these arguments on a clean tree.
        public var isCurrent: Bool {
            guard let file, let state, FileManager.default.fileExists(atPath: map.path) else { return false }
            return (try? String(contentsOf: file, encoding: .utf8)) == state
        }

        /// Forgets any earlier stamp, so a run that fails leaves none to skip on.
        public func clear() {
            if let file { try? FileManager.default.removeItem(at: file) }
        }

        /// Stamps the map just written, when the tree was clean; a dirty tree leaves no stamp.
        public func record() throws {
            clear()
            if let file, let state { try state.write(to: file, atomically: true, encoding: .utf8) }
        }
    }
#endif
