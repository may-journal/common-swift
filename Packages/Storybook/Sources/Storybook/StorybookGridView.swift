import StorybookKit
import SwiftUI

/// Every page of one component as a grid of preview cards, as many columns across as the
/// header's device has room for. Tapping a card opens its page alone.
struct StorybookGridView: View {
    let group: StorybookCatalog.Group
    let catalog: StorybookCatalog
    let anchor: UnitPoint
    let store: UserDefaults
    @Binding var selection: StorybookSelection?
    @Binding var appearance: ColorScheme?

    var body: some View {
        StorybookBoard(kind: .grid, anchor: anchor) { width in
            let columns = StorybookLayout.columns(in: width)
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(
                        .fixed(StorybookLayout.cellWidth(in: width)),
                        spacing: StorybookLayout.gap),
                    count: columns),
                spacing: StorybookLayout.gap
            ) {
                ForEach(group.pages) { page in
                    card(page, height: columns == 1 ? 480 : 360)
                }
            }
            .padding(StorybookLayout.gap)
        }
        .accessibilityIdentifier("storybook.grid.\(group.id)")
        .navigationTitle(Text(group.id))
        .storybookInlineTitle()
        .toolbar {
            ToolbarItem(placement: .principal) { header }
            ToolbarItemGroup(placement: .storybookTrailing) {
                StorybookHeaderToggles(appearance: $appearance)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            Text(group.id)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(StorybookWords.pageCount(group.pages.count))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    /// A page's preview, its ID chip and meter over its top corners, above its short name, age
    /// and caption. The preview takes no touches, so a tap anywhere on the card opens the
    /// page, where the preview can be used.
    private func card(_ page: BookPage, height: CGFloat) -> some View {
        let id = StorybookCatalog.acceptanceID(of: page)
        let badge = catalog.badge(of: page)
        return Button {
            selection = .page(page.id)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                if let id {
                    HStack {
                        StorybookIDChip(id: id, badge: badge)
                        Spacer()
                        if let badge { StorybookMeter(level: StorybookFreshness(badge).level) }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    .layoutPriority(1)
                }
                StorybookCardPreview(make: page.destination, store: store)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                Divider()
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(StorybookCatalog.shortTitle(of: page))
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        if let badge { StorybookAgeMeter(badge: badge, showsMeter: false) }
                    }
                    if id != nil { StorybookBadgeCaption(badge: badge) }
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .layoutPriority(1)
            }
            .frame(height: height)
            .background(Color.storybookPage)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12).strokeBorder(.separator)
            }
            .contentShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(StorybookCatalog.shortTitle(of: page)))
        .accessibilityValue(
            Text(verbatim: id.map { "\($0), \(StorybookWords.badge(badge))" } ?? ""))
        .accessibilityIdentifier("storybook.card.\(page.descriptor.accessibilityIdentifier)")
    }
}

/// A card's preview in its own hosting controller keeps Storybook's toolbar buttons off the
/// grid's header. It starts a new environment, so the card names the header's store again.
@MainActor
private func storybookCardRoot(_ make: @escaping () -> AnyView, _ store: UserDefaults) -> AnyView {
    AnyView(
        StorybookPreviewContent(make: make)
            .storybookPreviewSettings()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.storybookPage)
            .defaultAppStorage(store))
}

#if os(iOS)
    private struct StorybookCardPreview: UIViewControllerRepresentable {
        let make: () -> AnyView
        let store: UserDefaults

        func makeUIViewController(context: Context) -> UIHostingController<AnyView> {
            let controller = UIHostingController(rootView: storybookCardRoot(make, store))
            controller.view.backgroundColor = .systemBackground
            return controller
        }

        func updateUIViewController(_ controller: UIHostingController<AnyView>, context: Context) {}
    }
#else
    private struct StorybookCardPreview: NSViewControllerRepresentable {
        let make: () -> AnyView
        let store: UserDefaults

        /// The preview takes the card's room, so a tall one never pushes out the chip and caption.
        func makeNSViewController(context: Context) -> NSHostingController<AnyView> {
            let controller = NSHostingController(rootView: storybookCardRoot(make, store))
            controller.sizingOptions = []
            return controller
        }

        func updateNSViewController(_ controller: NSHostingController<AnyView>, context: Context) {}
    }
#endif
