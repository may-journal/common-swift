// cspell:ignore pathspecs
#if os(macOS)
    import Foundation

    /// Reads when the code behind each requirement acceptance last changed into a
    /// `StorybookHistory`, as the StorybookHistory build plugin does on every build. The coverage
    /// map, which the StorybookCoverage plugin writes, names each acceptance's files.
    public enum StorybookHistoryReader {
        /// The folder that holds a repo's requirement docs.
        public static let docs = "docs/requirements"
        /// The coverage map: each acceptance's ID mapped to the repo files its test covers.
        public static let coverage = "docs/requirements/coverage.json"

        /// The history of the repo holding `directory`, or nil without git or a commit. A shallow
        /// clone has none either, since its oldest commit would mark every acceptance New.
        public static func read(_ directory: URL) -> StorybookHistory? {
            guard let root = git(["rev-parse", "--show-toplevel"], in: directory),
                git(["rev-parse", "--is-shallow-repository"], in: directory) == "false"
            else { return nil }
            let repo = URL(filePath: root)
            // Every mainline commit, newest first: the build's own, then its first parents.
            guard let mainline = git(["log", "--first-parent", "--format=%H %aI", "HEAD"], in: repo)
            else { return nil }
            let commits = mainline.split(separator: "\n").compactMap(Commit.init)
            guard let head = commits.first else { return nil }
            let docs = requirementDocs(in: repo)
            let thens = thenLines(in: docs)
            var acceptances: [String: StorybookHistory.Acceptance] = [:]
            for (id, change) in changes(of: files(in: repo), in: repo, mainline: commits) {
                guard let then = thens[id] else { continue }
                acceptances[id] = StorybookHistory.Acceptance(
                    changed: change.commit.date, changedIn: change.commit.hash, commitsAgo: change.ago, then: then)
            }
            return StorybookHistory(
                commit: head.hash, buildDate: head.date, acceptances: acceptances,
                requirements: StorybookRequirementDoc.titles(in: docs))
        }

        /// One mainline commit: its hash and author date, from a `%H %aI` line.
        struct Commit {
            let hash: String
            let date: Date

            init?(_ line: Substring) {
                let parts = line.split(separator: " ", maxSplits: 1).map(String.init)
                guard parts.count == 2, let date = try? Date(parts[1], strategy: .iso8601) else { return nil }
                hash = parts[0]
                self.date = date
            }
        }

        /// Each acceptance's files from the coverage map, or else the file declaring its test at
        /// HEAD, the first by path when several do. An acceptance with neither has no files.
        static func files(in repo: URL) -> [String: [String]] {
            var map = coverageMap(in: repo)
            for test in StorybookRequirementTests.declarations(in: repo, at: "HEAD") where map[test.id] == nil {
                map[test.id] = [test.path]
            }
            return map
        }

        /// The coverage map in the repo's working tree, or none when it is missing or unreadable.
        static func coverageMap(in repo: URL) -> [String: [String]] {
            guard let data = try? Data(contentsOf: repo.appending(path: coverage)) else { return [:] }
            return (try? JSONDecoder().decode([String: [String]].self, from: data)) ?? [:]
        }

        /// Each acceptance's newest mainline commit touching one of its files, and the mainline
        /// commits since. One `git log` diffs each against its first parent, so a merge or rename counts.
        static func changes(
            of map: [String: [String]], in repo: URL, mainline: [Commit]
        ) -> [String: (commit: Commit, ago: Int)] {
            var owners: [String: [String]] = [:]
            for (id, files) in map {
                for file in files { owners[file, default: []].append(id) }
            }
            guard !owners.isEmpty else { return [:] }
            let ago = Dictionary(mainline.enumerated().map { ($1.hash, $0) }) { first, _ in first }
            let arguments =
                ["log", "--first-parent", "--diff-merges=first-parent", "--name-only", "--format=%x00%H %aI"]
                + ["HEAD", "--"] + owners.keys.sorted()
            var found: [String: (commit: Commit, ago: Int)] = [:]
            for entry in (git(arguments, in: repo, literal: true) ?? "").split(separator: "\0") {
                let lines = entry.split(separator: "\n")
                guard let header = lines.first, let commit = Commit(header), let count = ago[commit.hash]
                else { continue }
                for file in lines.dropFirst() {
                    for id in owners[String(file)] ?? [] where found[id] == nil {
                        found[id] = (commit, count)
                    }
                }
                if found.count == map.count { break }
            }
            return found
        }

        /// Every requirement doc at HEAD, one after another, leaving out the template.
        static func requirementDocs(in repo: URL) -> String {
            let files = (git(["ls-tree", "--name-only", "HEAD", "\(docs)/"], in: repo) ?? "")
                .split(separator: "\n")
                .filter { $0.hasSuffix(".md") && !$0.hasSuffix("/template.md") }
            guard !files.isEmpty else { return "" }
            // One call shows every doc; each starts with its title, which ends the doc before it.
            return git(["show"] + files.map { "HEAD:\($0)" }, in: repo) ?? ""
        }

        /// Each acceptance's Then line, from the requirement docs' bodies.
        static func thenLines(in bodies: String) -> [String: String] {
            var thens: [String: String] = [:]
            for block in StorybookRequirementDoc.acceptances(in: bodies) where thens[block.id] == nil {
                thens[block.id] = block.then
            }
            return thens
        }

        /// Runs git in `directory` and returns its output trimmed, or nil when it fails. Paths print
        /// unquoted, as the coverage map spells them; a literal call reads its paths as written.
        static func git(_ arguments: [String], in directory: URL, literal: Bool = false) -> String? {
            let process = Process()
            process.executableURL = URL(filePath: "/usr/bin/git")
            process.arguments =
                ["-C", directory.path(percentEncoded: false), "-c", "core.quotePath=false"]
                + (literal ? ["--literal-pathspecs"] : []) + arguments
            let output = Pipe()
            process.standardOutput = output
            process.standardError = FileHandle.nullDevice
            guard (try? process.run()) != nil else { return nil }
            let data = output.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            return String(bytes: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
#endif
