import StorybookKit
import SwiftUI

/// The catalog as master and detail: the grouped list of previews stays in the sidebar while
/// the chosen preview fills the detail column. In compact width the split view collapses to a
/// stack, where previous, next and a page picker make the list rarely needed.
struct StorybookNavigator: View {
    let close: () -> Void

    @State private var catalog: StorybookCatalog
    @State private var selection: StorybookSelection?
    @State private var launchProblem: String?
    @State private var compactColumn: NavigationSplitViewColumn
    @State private var appearance: ColorScheme?
    @State private var query = ""
    private let anchor: UnitPoint
    /// The store the header writes, which grid cards read in their own hosting controllers.
    private let store: UserDefaults

    /// SwiftUI reruns this on every redraw beneath, so the availability scans and resolves once.
    init(availability: StorybookAvailability, close: @escaping () -> Void) {
        self.close = close
        anchor = StorybookBoardAnchor.anchor(in: availability.configuration.arguments)
        store = availability.defaults
        let opening = availability.currentOpening
        _catalog = State(initialValue: availability.catalog)
        _selection = State(initialValue: opening.selection)
        _launchProblem = State(initialValue: opening.problem)
        let opensPage = opening.selection != nil || opening.problem != nil
        _compactColumn = State(initialValue: opensPage ? .detail : .sidebar)
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $compactColumn) {
            sidebar
                .navigationSplitViewColumnWidth(min: 240, ideal: 300, max: 420)
        } detail: {
            NavigationStack { detail }
                // A preview may push its own screens; another page starts from its root.
                .id(selection)
        }
        .navigationSplitViewStyle(.balanced)
        // The whole catalog, bars included, takes one appearance, so titles stay legible.
        .preferredColorScheme(appearance)
    }

    private var sidebar: some View {
        List(selection: $selection) {
            ForEach(visibleGroups) { group in
                Section {
                    groupRow(group)
                    ForEach(group.pages) { page in
                        Text(StorybookCatalog.shortTitle(of: page))
                            .tag(StorybookSelection.page(page.id))
                            .accessibilityAddTraits(.isButton)
                            .accessibilityAction { open(.page(page.id)) }
                    }
                } header: {
                    Text(group.id)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(Text(StorybookWords.name))
        .searchable(text: $query, placement: .sidebar, prompt: Text(StorybookWords.search))
        #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { closeButton }
            }
        #else
            // The catalog lies over the app's window, whose toolbar belongs to the app.
            .safeAreaInset(edge: .top) {
                HStack {
                    closeButton
                    Spacer()
                }
                .padding(.horizontal, StorybookLayout.gap)
                .padding(.vertical, 8)
            }
        #endif
    }

    private var closeButton: some View {
        Button(StorybookWords.done, systemImage: "xmark", action: close)
            .keyboardShortcut(.cancelAction)
            .accessibilityIdentifier("storybook.close")
    }

    /// The component's pages side by side, as many across as the device has room for.
    private func groupRow(_ group: StorybookCatalog.Group) -> some View {
        Label {
            Text(StorybookWords.allPages)
        } icon: {
            Image(systemName: "square.grid.2x2")
        }
        .tag(StorybookSelection.group(group.id))
        .accessibilityIdentifier("storybook.group.\(group.id)")
        // VoiceOver reads a sidebar row as plain text, and its double tap selects nothing.
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { open(.group(group.id)) }
    }

    @ViewBuilder private var detail: some View {
        if let group = selectedGroup {
            StorybookGridView(
                group: group, anchor: anchor, store: store, selection: $selection,
                appearance: $appearance)
        } else if let page = catalog.page(selection?.page) {
            StorybookPageView(
                page: page, catalog: catalog, anchor: anchor, selection: $selection,
                appearance: $appearance)
        } else if let launchProblem {
            empty(StorybookWords.noPreviewOpened, "magnifyingglass", launchProblem)
        } else {
            empty(StorybookWords.choosePreview, "sidebar.left", StorybookWords.pickPage)
        }
    }

    /// The component whose pages the sidebar's All Pages row chose, if any.
    private var selectedGroup: StorybookCatalog.Group? {
        guard case .group(let id) = selection else { return nil }
        return catalog.groups.first { $0.id == id }
    }

    /// Selects `choice` and shows it, as a tap on its row does on a phone too.
    private func open(_ choice: StorybookSelection) {
        selection = choice
        compactColumn = .detail
    }

    private func empty(_ title: String, _ symbol: String, _ detail: String) -> some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text(detail))
    }

    /// The groups whose component or page names contain the search text.
    private var visibleGroups: [StorybookCatalog.Group] {
        guard query.isEmpty == false else { return catalog.groups }
        return catalog.groups.compactMap { group in
            if group.id.localizedStandardContains(query) { return group }
            let pages = group.pages.filter { $0.title.localizedStandardContains(query) }
            return pages.isEmpty ? nil : .init(id: group.id, pages: pages)
        }
    }
}
