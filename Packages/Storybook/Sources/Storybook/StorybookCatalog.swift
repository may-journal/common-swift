import Foundation
import StorybookKit

/// What the sidebar has chosen: one component's pages side by side, or one page alone.
enum StorybookSelection: Hashable {
    case group(String)
    case page(DeclarationIdentifier)

    var page: DeclarationIdentifier? {
        if case .page(let id) = self { return id }
        return nil
    }
}

/// Where the catalog opens: a page or component, or why the launch named neither.
struct StorybookOpening {
    var selection: StorybookSelection?
    var problem: String?
}

/// Every `#Preview` and app page, each under its requirement, such as 0006 for "0006.3 unlocked",
/// or else its component, such as CaptionEditorView.
@MainActor
struct StorybookCatalog {
    /// One requirement's pages in acceptance order, or one component's in the order its file
    /// declares them. The ID, a requirement's number or a component's name, stays put when a
    /// doc's title changes; a launch names either.
    struct Group: Identifiable {
        let id: String
        let title: String
        let pages: [BookPage]
    }

    let store: BookStore
    let groups: [Group]
    /// Every page in sidebar order, for previous and next.
    let pages: [BookPage]
    /// When each acceptance was added and changed, for the pages' badges.
    let history: StorybookHistory?
    /// The title of the group each page sits under, for the page's header.
    private let titles: [DeclarationIdentifier: String]

    init(pages added: [BookPage], history: StorybookHistory? = nil) {
        self.history = history
        // The store holds only the host's pages, so a launch can never select a hidden one.
        let hosts = (Self.pages(in: Book.allBookPreviews() ?? []) + added).filter(Self.isHosts)
        store = BookStore(book: Book(title: StorybookWords.name) { hosts })
        // Requirements come first by number, then components by name.
        let named = Dictionary(grouping: hosts.filter { Self.acceptanceID(of: $0) != nil }, by: Self.requirement)
            .sorted { $0.key < $1.key }
            .map {
                Group(id: $0.key, title: Self.title(of: $0.key, in: history),
                      pages: $0.value.sorted(by: Self.acceptanceOrder))
            }
        let others = Dictionary(grouping: hosts.filter { Self.acceptanceID(of: $0) == nil }, by: Self.component)
            .sorted { $0.key.localizedStandardCompare($1.key) == .orderedAscending }
            .map { Group(id: $0.key, title: $0.key, pages: $0.value.sorted(by: Self.sourceOrder)) }
        groups = named + others
        pages = groups.flatMap(\.pages)
        titles = Dictionary(
            groups.flatMap { group in group.pages.map { ($0.id, group.title) } }) { first, _ in first }
    }

    /// The title of the group `page` sits under, as the sidebar shows it.
    func group(of page: BookPage) -> String {
        titles[page.id] ?? ""
    }

    /// The badge a page earns from its acceptance's history, if the build bundled one.
    func badge(of page: BookPage) -> StorybookBadge? {
        guard let id = Self.acceptanceID(of: page) else { return nil }
        return history?.badge(for: id)
    }

    /// The Then line of the acceptance a page shows, if the build bundled its history.
    func then(of page: BookPage) -> String? {
        guard let id = Self.acceptanceID(of: page) else { return nil }
        return history?.acceptances[id]?.then
    }

    func page(_ id: DeclarationIdentifier?) -> BookPage? {
        pages.first { $0.id == id }
    }

    /// The page `offset` places after `id` in sidebar order, if there is one.
    func page(after id: DeclarationIdentifier?, offset: Int) -> BookPage? {
        guard let index = pages.firstIndex(where: { $0.id == id }) else { return nil }
        let target = index + offset
        return pages.indices.contains(target) ? pages[target] : nil
    }

    /// What a `--storybook "<name>"` launch selects: the page of that name, else that group's grid.
    /// A group answers to its number, name or title; with no match, the opening says why.
    func opening(for request: StorybookLaunchRequest) -> StorybookOpening {
        switch request {
        case .catalog:
            return StorybookOpening()
        case .page(let selector):
            return opening(for: selector)
        case .invalid(let diagnostic):
            return StorybookOpening(problem: diagnostic.message)
        }
    }

    private func opening(for selector: BookPageSelector) -> StorybookOpening {
        do {
            return StorybookOpening(selection: .page(try store.resolve(selector).id))
        } catch BookPageResolutionError.ambiguous(_, let candidates) {
            // Name every match, so the launch can add --storybook-file and --storybook-line.
            let places = candidates.map { "\($0.fileID):\($0.line)" }
            return StorybookOpening(problem: StorybookWords.manyPages(named: selector.name, places))
        } catch {
            if selector.fileID == nil,
                let group = groups.first(where: { $0.id == selector.name || $0.title == selector.name }) {
                return StorybookOpening(selection: .group(group.id))
            }
            return StorybookOpening(problem: StorybookWords.noPage(named: selector.name))
        }
    }

    /// The requirement a page named by an acceptance belongs to: "0006" for "0006.3 unlocked".
    static func requirement(of page: BookPage) -> String {
        String(acceptanceID(of: page)?.prefix(4) ?? "")
    }

    /// A requirement's group title: its number and its doc's title, or its number alone when the
    /// build bundled no titles.
    static func title(of requirement: String, in history: StorybookHistory?) -> String {
        guard let title = history?.requirements?[requirement] else { return requirement }
        return "\(requirement) \(title)"
    }

    /// A page's component: its name before ": ", else its file's name. It groups a page with no acceptance.
    static func component(of page: BookPage) -> String {
        if let range = componentSeparator(in: page) {
            return String(page.title[..<range.lowerBound])
        }
        let file = (page.descriptor.fileID as NSString).lastPathComponent
        return (file as NSString).deletingPathExtension
    }

    /// The page's name within its component, so the header never repeats the component. A page
    /// named by an acceptance shows its label, or the ID when it has none.
    static func shortTitle(of page: BookPage) -> String {
        if let id = acceptanceID(of: page) {
            let label = page.title.dropFirst(id.count).trimmingCharacters(in: .whitespaces)
            return label.isEmpty ? id : label
        }
        guard let range = componentSeparator(in: page) else { return page.title }
        return String(page.title[range.upperBound...])
    }

    /// The acceptance a page's name starts with, such as "0006.3" in "0006.3 unlocked".
    static func acceptanceID(of page: BookPage) -> String? {
        guard let match = page.title.prefixMatch(of: /[0-9]{4}\.[0-9]+(?= |$)/) else { return nil }
        return String(match.output)
    }

    /// Where a named page's component ends. An unnamed `#Preview` is titled "line: 42" by
    /// Storybook, and that names no component, nor does a page named by an acceptance.
    private static func componentSeparator(in page: BookPage) -> Range<String.Index>? {
        guard page.title.hasPrefix("line: ") == false, acceptanceID(of: page) == nil else { return nil }
        return page.title.range(of: ": ")
    }

    /// Whether the host declares `page`, unlike the demo `#Preview` StorybookKit ships.
    private static func isHosts(_ page: BookPage) -> Bool {
        !page.descriptor.fileID.hasPrefix("StorybookKit/")
    }

    private static func pages(in nodes: [Book.Node]) -> [BookPage] {
        nodes.flatMap { node -> [BookPage] in
            switch node {
            case .folder(let folder): return pages(in: folder.contents)
            case .page(let page): return [page]
            }
        }
    }

    /// By acceptance number, so 0002.10 follows 0002.9; pages of one acceptance in source order.
    private static func acceptanceOrder(_ lhs: BookPage, _ rhs: BookPage) -> Bool {
        let left = acceptanceNumber(of: lhs)
        let right = acceptanceNumber(of: rhs)
        return left == right ? sourceOrder(lhs, rhs) : left < right
    }

    /// The number after the dot in a page's acceptance: 10 for "0002.10".
    private static func acceptanceNumber(of page: BookPage) -> Int {
        Int(acceptanceID(of: page)?.split(separator: ".").last ?? "") ?? 0
    }

    private static func sourceOrder(_ lhs: BookPage, _ rhs: BookPage) -> Bool {
        if lhs.descriptor.fileID != rhs.descriptor.fileID {
            return lhs.descriptor.fileID < rhs.descriptor.fileID
        }
        return (Int(lhs.descriptor.line) ?? 0) < (Int(rhs.descriptor.line) ?? 0)
    }
}
