import StorybookKit
import SwiftUI

/// One preview in the detail column, under a header naming its page and component, with
/// previous and next along the bottom. The preview fills the header's device frame, or the
/// whole pane on Auto.
struct StorybookPageView: View {
    let page: BookPage
    let catalog: StorybookCatalog
    let anchor: UnitPoint
    @Binding var selection: StorybookSelection?
    @Binding var appearance: ColorScheme?

    var body: some View {
        StorybookBoard(kind: .page, anchor: anchor) { _ in
            StorybookPreviewContent(make: page.destination)
                .storybookPreviewSettings()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.storybookPage)
                .accessibilityIdentifier(page.descriptor.accessibilityIdentifier)
        }
        .navigationTitle(Text(page.title))
        .storybookInlineTitle()
        .toolbar {
            ToolbarItem(placement: .principal) { header }
            ToolbarItemGroup(placement: .storybookTrailing) {
                StorybookHeaderToggles(appearance: $appearance)
            }
            ToolbarItemGroup(placement: .storybookStepper) {
                StorybookStepper(page: page, catalog: catalog, selection: $selection)
            }
        }
    }

    /// The page's name may wrap to two lines rather than end in an ellipsis.
    private var header: some View {
        VStack(spacing: 0) {
            Text(StorybookCatalog.shortTitle(of: page))
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(StorybookCatalog.component(of: page))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// Previous and next, with the page's position between them. In compact width the position
/// opens a picker of every page, grouped as in the hidden sidebar.
private struct StorybookStepper: View {
    let page: BookPage
    let catalog: StorybookCatalog
    @Binding var selection: StorybookSelection?

    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var sizeClass
        private var isCompact: Bool { sizeClass == .compact }
    #else
        private let isCompact = false
    #endif

    var body: some View {
        let previous = catalog.page(after: page.id, offset: -1)
        let next = catalog.page(after: page.id, offset: 1)
        Button {
            selection = previous.map { .page($0.id) }
        } label: {
            storybookLabel(StorybookWords.previous, "chevron.left")
        }
        .disabled(previous == nil)
        .keyboardShortcut("[", modifiers: .command)
        .accessibilityIdentifier("storybook.page.previous")
        Spacer()
        if isCompact { picker } else { positionText }
        Spacer()
        Button {
            selection = next.map { .page($0.id) }
        } label: {
            storybookLabel(StorybookWords.next, "chevron.right")
        }
        .disabled(next == nil)
        .keyboardShortcut("]", modifiers: .command)
        .accessibilityIdentifier("storybook.page.next")
    }

    private var positionText: some View {
        Text(position)
            .font(.footnote.monospacedDigit())
            .foregroundStyle(.secondary)
    }

    private var picker: some View {
        Menu {
            Picker(selection: $selection) {
                ForEach(catalog.groups) { group in
                    Section(group.id) {
                        ForEach(group.pages) { page in
                            Text(StorybookCatalog.shortTitle(of: page))
                                .tag(Optional(StorybookSelection.page(page.id)))
                        }
                    }
                }
            } label: {
                EmptyView()
            }
        } label: {
            // A compact bar drops the header for its buttons, so the page's name rides here.
            VStack(spacing: 0) {
                Text(StorybookCatalog.shortTitle(of: page))
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                positionText
            }
        }
        .accessibilityLabel(Text(StorybookWords.pages))
        .accessibilityValue(Text(pickerValue))
        .accessibilityIdentifier("storybook.page.picker")
    }

    /// "Empty, 3 / 12": the page and where it sits, as the picker reads aloud.
    private var pickerValue: String {
        "\(StorybookCatalog.shortTitle(of: page)), \(position)"
    }

    private var position: String {
        let index = catalog.pages.firstIndex { $0.id == page.id } ?? 0
        return "\(index + 1) / \(catalog.pages.count)"
    }
}

/// Builds the preview once, when it first appears, as Storybook's own page does.
struct StorybookPreviewContent: View {
    let make: () -> AnyView
    @State private var content: AnyView?

    var body: some View {
        if let content {
            content
        } else {
            Color.clear.onAppear { content = make() }
        }
    }
}
