#if os(macOS)
    import Foundation

    /// The tests that prove requirement acceptances, found by name: Swift's `func test0006_3(` and
    /// Go's `func Test0006_3(` both prove 0006.3.
    public enum StorybookRequirementTests {
        /// One requirement test: the acceptance it proves, its name and the repo file declaring it.
        public struct Declaration: Hashable, Sendable {
            public let id: String
            public let test: String
            public let path: String
        }

        /// The acceptance a test name proves, such as 0006.3 for `test0006_3`, or nil for any other name.
        public static func acceptanceID(of test: String) -> String? {
            guard let match = test.wholeMatch(of: /[Tt]est(\d{4})_(\d+)/) else { return nil }
            return "\(match.1).\(match.2)"
        }

        /// Every requirement test in the repo's tracked Swift and Go files, sorted by path then name.
        /// It reads the working tree, or the commit `revision` names.
        public static func declarations(in repo: URL, at revision: String? = nil) -> [Declaration] {
            let arguments =
                ["grep", "--null", "-o", "-E", #"func [Tt]est[0-9]{4}_[0-9]+\("#] + (revision.map { [$0] } ?? [])
                + ["--", "*.swift", "*.go"]
            let prefix = revision.map { "\($0):" } ?? ""
            var found: Set<Declaration> = []
            for line in (StorybookHistoryReader.git(arguments, in: repo) ?? "").split(separator: "\n") {
                let parts = line.split(separator: "\0", maxSplits: 1).map(String.init)
                guard parts.count == 2 else { continue }
                let path = String(parts[0].dropFirst(prefix.count))
                let test = String(parts[1].dropFirst("func ".count).dropLast())
                // Swift names its tests in lower case and Go in upper, so a Go file's Swift sample is no test.
                guard test.hasPrefix(path.hasSuffix(".go") ? "Test" : "test"), let id = acceptanceID(of: test)
                else { continue }
                found.insert(Declaration(id: id, test: test, path: path))
            }
            return found.sorted { ($0.path, $0.test) < ($1.path, $1.test) }
        }
    }
#endif
