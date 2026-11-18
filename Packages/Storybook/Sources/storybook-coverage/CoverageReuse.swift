// cspell:ignore xcconfig xctestplan xcodeproj xcworkspace
import Foundation
import StorybookHistoryKit

/// Picks the acceptances a run maps again, keeping the earlier map's rows for the rest. It reruns
/// what a change since the stamped commit can touch, and everything whenever it cannot tell.
enum CoverageReuse {
    /// Every acceptance, and why; or only some, with the earlier map's rows for the others.
    enum Plan {
        case full(String)
        case only(Set<String>, kept: [String: [String]])

        /// Whether the run maps the acceptance again.
        func maps(_ id: String) -> Bool {
            switch self {
            case .full: true
            case .only(let ids, _): ids.contains(id)
            }
        }
    }

    /// A share of acceptances above which one full run costs about the same and trusts nothing old.
    static let fullShare = 0.6

    /// The plan for this run, from the stamp of the last run that finished on a clean tree.
    static func plan(
        root: URL, recorded: (commit: String, settings: [String])?, settings: [String], map: URL,
        declarations: [StorybookRequirementTests.Declaration]
    ) -> Plan {
        guard let recorded else { return .full("no earlier map was stamped on a clean tree") }
        guard recorded.settings == settings else { return .full("the arguments differ from the earlier map's") }
        guard let data = try? Data(contentsOf: map),
            let kept = try? JSONSerialization.jsonObject(with: data) as? [String: [String]]
        else { return .full("the earlier map is missing") }
        guard (try? run(["git", "merge-base", "--is-ancestor", recorded.commit, "HEAD"], in: root)) != nil else {
            return .full("the earlier map's commit is not in HEAD's history")
        }
        let git = { (arguments: [String]) in
            ((try? run(["git", "-c", "core.quotePath=false"] + arguments, in: root)) ?? "")
                .split(separator: "\n").map(String.init)
        }
        let changed = Set(
            git(["diff", "--name-only", "--no-renames", recorded.commit])
                + git(["ls-files", "--others", "--exclude-standard"]))
        let ids = Set(declarations.map(\.id))
        var selected = ids.subtracting(kept.keys)
        for file in changed.sorted() {
            if isBuildSetting(file) { return .full("\(file) changes the build") }
            if let doc = file.wholeMatch(of: /docs\/requirements\/(\d{4})-[^\/]*\.md/) {
                selected.formUnion(ids.filter { $0.hasPrefix("\(doc.1).") })
                continue
            }
            let declared = declarations.filter { $0.path == file }.map(\.id)
            let covering = kept.filter { $0.value.contains(file) }.map(\.key)
            if declared.isEmpty, covering.isEmpty {
                // Code no row lists, the catalog's own included, may be what a test now reaches, so
                // nothing old is trusted.
                if isCode(file) {
                    return .full("\(file) is code that no row of the earlier map lists")
                }
                continue
            }
            selected.formUnion(declared + covering.filter(ids.contains))
        }
        if Double(selected.count) > fullShare * Double(ids.count) {
            return .full("\(selected.count) of \(ids.count) acceptances changed")
        }
        return .only(selected, kept: kept)
    }

    /// Project, package, build settings, plist and entitlements files, which can change every test.
    static func isBuildSetting(_ file: String) -> Bool {
        let name = file.split(separator: "/").last.map(String.init) ?? file
        let names = ["project.yml", "Package.swift", "Package.resolved", "go.mod", "go.sum"]
        let kinds = [".xcconfig", ".entitlements", ".xctestplan", "Info.plist"]
        return names.contains(name) || kinds.contains { name.hasSuffix($0) }
            || file.contains(".xcodeproj/") || file.contains(".xcworkspace/")
    }

    /// Source files a coverage profile can list.
    static func isCode(_ file: String) -> Bool {
        let kinds = ["swift", "go", "m", "mm", "c", "cc", "cpp", "h", "hpp", "metal", "s"]
        return kinds.contains(URL(filePath: file).pathExtension)
    }
}
