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

/// Every `#Preview` that Storybook finds, and every page the app adds. Each sits under the
/// component its name starts with: "CaptionEditorView: dark" sits under CaptionEditorView.
@MainActor
struct StorybookCatalog {
    /// One component's pages, in the order its file declares them.
    struct Group: Identifiable {
        let id: String
        let pages: [BookPage]
    }

    let store: BookStore
    let groups: [Group]
    /// Every page in sidebar order, for previous and next.
    let pages: [BookPage]

    init(pages added: [BookPage]) {
        // The store holds only the host's pages, so a launch can never select a hidden one.
        let hosts = (Self.pages(in: Book.allBookPreviews() ?? []) + added).filter(Self.isHosts)
        store = BookStore(book: Book(title: StorybookWords.name) { hosts })
        groups = Dictionary(grouping: hosts, by: Self.component)
            .sorted { $0.key.localizedStandardCompare($1.key) == .orderedAscending }
            .map { Group(id: $0.key, pages: $0.value.sorted(by: Self.sourceOrder)) }
        pages = groups.flatMap(\.pages)
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

    /// What a `--storybook "<name>"` launch selects, or why nothing matched: the page of that
    /// name, else the grid of the component of that name.
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
            if selector.fileID == nil, groups.contains(where: { $0.id == selector.name }) {
                return StorybookOpening(selection: .group(selector.name))
            }
            return StorybookOpening(problem: StorybookWords.noPage(named: selector.name))
        }
    }

    /// The component a page belongs to: its name before ": ", else its file's name.
    static func component(of page: BookPage) -> String {
        if let range = componentSeparator(in: page) {
            return String(page.title[..<range.lowerBound])
        }
        let file = (page.descriptor.fileID as NSString).lastPathComponent
        return (file as NSString).deletingPathExtension
    }

    /// The page's name within its component, so the header never repeats the component.
    static func shortTitle(of page: BookPage) -> String {
        guard let range = componentSeparator(in: page) else { return page.title }
        return String(page.title[range.upperBound...])
    }

    /// Where a named page's component ends. An unnamed `#Preview` is titled "line: 42" by
    /// Storybook, and that names no component.
    private static func componentSeparator(in page: BookPage) -> Range<String.Index>? {
        guard page.title.hasPrefix("line: ") == false else { return nil }
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

    private static func sourceOrder(_ lhs: BookPage, _ rhs: BookPage) -> Bool {
        if lhs.descriptor.fileID != rhs.descriptor.fileID {
            return lhs.descriptor.fileID < rhs.descriptor.fileID
        }
        return (Int(lhs.descriptor.line) ?? 0) < (Int(rhs.descriptor.line) ?? 0)
    }
}
