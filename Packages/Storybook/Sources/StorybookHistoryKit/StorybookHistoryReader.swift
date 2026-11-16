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

        /// The tracked requirement docs, leaving out the template.
        static func requirementDocs(in repo: URL) -> [String] {
            let files = git(["ls-files", "--", "\(docs)/*.md"], in: repo) ?? ""
            return files.split(separator: "\n").map(String.init)
                .filter { !$0.hasSuffix("/template.md") }
        }

        /// Each acceptance in one doc: the commit that first held it, the last commit that
        /// changed its lines, and its Then line now.
        static func history(of doc: String, in repo: URL) -> [String: StorybookHistory.Acceptance] {
            let log = git(["log", "--reverse", "--format=%H %cI", "--", doc], in: repo) ?? ""
            var seen: [String: (acceptance: StorybookHistory.Acceptance, lines: String)] = [:]
            for entry in log.split(separator: "\n") {
                let parts = entry.split(separator: " ", maxSplits: 1).map(String.init)
                guard parts.count == 2, let date = try? Date(parts[1], strategy: .iso8601),
                    let body = git(["show", "\(parts[0]):\(doc)"], in: repo)
                else { continue }
                for block in StorybookRequirementDoc.acceptances(in: body) {
                    if var known = seen[block.id] {
                        if known.lines != block.lines { known.acceptance.changed = date }
                        known.acceptance.then = block.then
                        known.lines = block.lines
                        seen[block.id] = known
                    } else {
                        let acceptance = StorybookHistory.Acceptance(
                            added: date, addedIn: parts[0], changed: date, then: block.then)
                        seen[block.id] = (acceptance, block.lines)
                    }
                }
            }
            return seen.mapValues(\.acceptance)
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
