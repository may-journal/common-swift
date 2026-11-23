import Foundation

/// The commit and settings the coverage map was written for, kept in the checkout's git folder.
/// The tool skips a run on a clean tree whose stamp matches, though git sees no ignored input.
struct CoverageStamp {
    /// The root of the repo the map belongs to.
    let repo: URL
    /// The map the stamp vouches for.
    let map: URL
    /// The stamp file, or nil outside a git repo.
    let file: URL?
    /// HEAD and the settings, or nil on a dirty tree, whose map matches no commit.
    let state: String?

    /// Reads HEAD and the tree's state now, before the tool runs any test. `settings` names
    /// each input with its paths resolved, so the same arguments typed elsewhere still differ.
    init(repo: URL, map: URL, settings: [String]) {
        self.repo = repo
        self.map = map
        let git = { (arguments: [String]) in
            (try? run(["git"] + arguments, in: repo))?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        file = git(["rev-parse", "--path-format=absolute", "--git-path", "storybook-coverage.commit"])
            .map { URL(filePath: $0) }
        // An untracked file counts as dirty, since a new test changes what the map lists.
        let clean = git(["status", "--porcelain", "--untracked-files=all"]) == ""
        state = git(["rev-parse", "HEAD"]).flatMap { clean ? ([$0] + settings).joined(separator: "\n") + "\n" : nil }
    }

    /// True when the map exists and was written for this commit and these settings on a clean tree.
    var isCurrent: Bool {
        guard let file, let state, FileManager.default.fileExists(atPath: map.path) else { return false }
        return (try? String(contentsOf: file, encoding: .utf8)) == state
    }

    /// Whether git ignores the map; a map it sees dirties the tree, so no run skips.
    var mapIgnored: Bool {
        (try? run(["git", "check-ignore", "-q", map.path(percentEncoded: false)], in: repo)) != nil
    }

    /// Forgets any earlier stamp, so a run that fails leaves none to skip on.
    func clear() {
        if let file { try? FileManager.default.removeItem(at: file) }
    }

    /// Stamps the map just written, when the tree was clean. A stamp that cannot be written only
    /// costs the next run its skip, so it never fails the run.
    func record() {
        if let file, let state { try? state.write(to: file, atomically: true, encoding: .utf8) }
    }
}
