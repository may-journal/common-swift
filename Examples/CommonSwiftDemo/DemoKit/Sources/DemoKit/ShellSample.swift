import AdaptiveShell
import SwiftUI

/// A small diary drawn by the real AdaptiveShell. An iPad or the Mac shows its entries beside the
/// picked one, and an iPhone stacks them.
struct ShellSample: View {
    enum Page: Hashable {
        case entry(String)
        case about
    }

    let close: () -> Void
    @State private var path: [Page] = []
    @State private var picked: String?

    var body: some View {
        AdaptiveShell(path: $path) { layout in
            List {
                Section {
                    ForEach(Self.entries, id: \.self) { entry in
                        Button(entry) { open(entry, layout) }
                    }
                }
                Section {
                    Button(DemoWords.about) { path.append(.about) }
                    Button(DemoWords.done, action: close)
                }
            }
            .navigationTitle(DemoWords.diary)
        } pane: {
            ShellPane(selection: picked) { entry in
                EntryView(entry: entry)
            } empty: {
                Text(DemoWords.pickEntry).foregroundStyle(.secondary)
            }
        } page: { page in
            switch page {
            case .entry(let entry): EntryView(entry: entry)
            case .about: Text(DemoWords.adaptiveShellSummary).navigationTitle(DemoWords.about)
            }
        }
    }

    /// A phone pushes the entry over the list; a split shows it in the pane.
    private func open(_ entry: String, _ layout: ShellLayout) {
        if layout == .stack {
            path.append(.entry(entry))
        } else {
            picked = entry
            path = []
        }
    }

    static var entries: [String] { [DemoWords.kites, DemoWords.dunes, DemoWords.tea] }
}

/// One diary entry, with the layout the shell drew it in.
private struct EntryView: View {
    let entry: String
    @Environment(\.shellLayout) private var layout

    var body: some View {
        VStack(spacing: 12) {
            Text(entry).font(.title)
            Text(layout == .split ? DemoWords.inPane : DemoWords.onStack).foregroundStyle(.secondary)
        }
        .navigationTitle(entry)
    }
}

extension View {
    /// A full-screen cover on iOS. The Mac has none, so the cover fills the window above the demo.
    @ViewBuilder func demoCover<Cover: View>(
        isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Cover
    ) -> some View {
        #if os(iOS)
            fullScreenCover(isPresented: isPresented, content: content)
        #else
            overlay {
                if isPresented.wrappedValue {
                    content().background(.background)
                }
            }
        #endif
    }
}
