#if os(macOS)
    import Foundation

    /// Reads a repo's git history of its requirement docs into a `StorybookHistory`, as the
    /// StorybookHistory build plugin does on every build.
    public enum StorybookHistoryReader {
        /// The folder that holds a repo's requirement docs.
        public static let docs = "docs/requirements"

        /// The history of the repo holding `directory`, or nil without git or a commit. A shallow
        /// clone has none either, since its oldest commit would mark every acceptance New.
        public static func read(_ directory: URL) -> StorybookHistory? {
            guard let root = git(["rev-parse", "--show-toplevel"], in: directory),
                git(["rev-parse", "--is-shallow-repository"], in: directory) == "false",
                let head = git(["rev-parse", "HEAD"], in: directory)
            else { return nil }
            let repo = URL(filePath: root)
            var acceptances: [String: StorybookHistory.Acceptance] = [:]
            for doc in requirementDocs(in: repo) {
                acceptances.merge(history(of: doc, in: repo)) { first, _ in first }
            }
            return StorybookHistory(commit: head, acceptances: acceptances)
        }

        /// The tracked requirement docs directly in `docs`, leaving out the template.
        static func requirementDocs(in repo: URL) -> [String] {
            let files = git(["ls-files", "--", ":(glob)\(docs)/*.md"], in: repo) ?? ""
            return files.split(separator: "\n").map(String.init)
                .filter { !$0.hasSuffix("/template.md") }
        }

        /// Each acceptance in one doc: the commit that first held it, the last commit that
        /// changed its lines, and its Then line now. It walks the mainline by author date, following renames.
        static func history(of doc: String, in repo: URL) -> [String: StorybookHistory.Acceptance] {
            var seen: [String: (acceptance: StorybookHistory.Acceptance, lines: String)] = [:]
            for commit in commits(of: doc, in: repo) {
                guard let body = git(["show", "\(commit.hash):\(commit.path)"], in: repo) else { continue }
                for block in StorybookRequirementDoc.acceptances(in: body) {
                    if var known = seen[block.id] {
                        if known.lines != block.lines { known.acceptance.changed = commit.date }
                        known.acceptance.then = block.then
                        known.lines = block.lines
                        seen[block.id] = known
                    } else {
                        let acceptance = StorybookHistory.Acceptance(
                            added: commit.date, addedIn: commit.hash, changed: commit.date, then: block.then)
                        seen[block.id] = (acceptance, block.lines)
                    }
                }
            }
            return seen.mapValues(\.acceptance)
        }

        /// A commit that touched a doc, and the path the doc had in it.
        struct Commit {
            let hash: String
            let date: Date
            let path: String
        }

        /// The mainline commits that touched `doc`, oldest first, each with the path the doc had then.
        static func commits(of doc: String, in repo: URL) -> [Commit] {
            let arguments = ["log", "--first-parent", "--follow", "--name-only", "--format=%x00%H %aI", "--", doc]
            var path = doc
            var commits: [Commit] = []
            for entry in (git(arguments, in: repo) ?? "").split(separator: "\0") {
                let lines = entry.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
                guard let header = lines.first else { continue }
                let parts = header.split(separator: " ", maxSplits: 1).map(String.init)
                guard parts.count == 2, let date = try? Date(parts[1], strategy: .iso8601) else { continue }
                // A commit without a listed name, such as a merge, keeps the newer commit's path.
                if lines.count > 1, let name = lines.last { path = name }
                commits.append(Commit(hash: parts[0], date: date, path: path))
            }
            return commits.reversed()
        }

        /// Runs git in `directory` and returns its output trimmed, or nil when it fails.
        static func git(_ arguments: [String], in directory: URL) -> String? {
            let process = Process()
            process.executableURL = URL(filePath: "/usr/bin/git")
            process.arguments = ["-C", directory.path(percentEncoded: false)] + arguments
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
