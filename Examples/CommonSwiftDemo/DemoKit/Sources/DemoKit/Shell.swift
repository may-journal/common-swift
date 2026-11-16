import AdaptiveShell
import StorybookKit
import SwiftUI

/// AdaptiveShell fitting and sharing the screen, listed under this file's name. Each page draws
/// a small shell from the package's own pieces, sized by its `ShellConfiguration`.
enum ShellPage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0010.1 Page over the sidebar") {
                ShellSample(.stack, path: [.settings])
            },
            BookPage(title: "0010.2 Page in the pane") { ShellSample(.split, path: [.settings]) },
            BookPage(title: "0010.3 Narrow split") { ShellSample(.split, path: [.settings]) },
            BookPage(title: "0010.4 Sidebar back") { ShellSample(.split, configuration: .hiding) },
            BookPage(title: "0010.5 Stack-only shell") { ShellSample(.stack, path: [.settings]) },
            BookPage(title: "0010.6 Prompt") { ShellSample(.split) },
            BookPage(title: "0010.7 Picked entry") { ShellSample(.split, picked: .storybook) },
            BookPage(title: "0010.8 Sidebar steps aside") {
                ShellSample(.split, configuration: .hiding, path: [.settings])
            },
            BookPage(title: "0013.1 Sidebar beside the pane") { ShellSample(.split) },
            BookPage(title: "0013.2 Title, symbol and message") {
                ShellPane(
                    selection: DemoPackage?.none, title: DemoWords.packages,
                    systemImage: "square.stack", message: DemoWords.prompt
                ) { Text($0.summary) }
            },
            BookPage(title: "0013.3 Narrowest sidebar") { ShellSample(.split, sidebar: \.min) },
            BookPage(title: "0013.4 Half the screen") { ShellSample(.split, sidebar: \.max) },
            BookPage(title: "0013.5 Six tenths") {
                ShellSample(.split, configuration: ShellConfiguration(sidebarMaxFraction: 0.6), sidebar: \.max)
            },
            BookPage(title: "0013.6 One-pixel line") { ShellSample(.split) },
            BookPage(title: "0013.7 No line") {
                ShellSample(.split, configuration: ShellConfiguration(sidebarBorder: .hidden))
            },
            BookPage(title: "0013.7 Two-point line") {
                ShellSample(.split, configuration: ShellConfiguration(sidebarBorder: SidebarBorder(width: 2)))
            },
            BookPage(title: "0013.8 Middle of the whole screen") {
                // The Duo's inner screen, 669 points with its side rail, and a wider Mac window.
                ShellSample(.split, sidebar: \.max, windowWidths: [669, 1440])
            }
        ]
    }
}

extension ShellConfiguration {
    /// A page moves the sidebar aside below 1000 points, wider than an iPad held upright.
    static var hiding: ShellConfiguration { ShellConfiguration(pageHidesSidebarBelow: 1000) }
}

/// A small shell of AdaptiveShell's pieces: `ShellRow`s, then `ShellPane` beside them or a page
/// over them. The rows really toggle, so a page can be tapped through.
struct ShellSample: View {
    private let layout: ShellLayout
    private let configuration: ShellConfiguration
    private let sidebar: KeyPath<ColumnWidth, CGFloat>
    private let windowWidths: [CGFloat]
    @State private var path: [DemoPage]
    @State private var picked: DemoPackage?
    @Environment(\.displayScale) private var displayScale

    /// A shell in `layout`, with `path` open and `picked` in the pane. A split draws the sidebar
    /// at the column width `sidebar` names, worked out for the window among `windowWidths`.
    init(
        _ layout: ShellLayout, configuration: ShellConfiguration = ShellConfiguration(),
        sidebar: KeyPath<ColumnWidth, CGFloat> = \.ideal, windowWidths: [CGFloat] = [],
        path: [DemoPage] = [], picked: DemoPackage? = nil
    ) {
        self.layout = layout
        self.configuration = configuration
        self.sidebar = sidebar
        self.windowWidths = windowWidths
        _path = State(initialValue: path)
        _picked = State(initialValue: picked)
    }

    var body: some View {
        GeometryReader { proxy in
            switch layout {
            case .stack:
                if let page = path.last { pageView(page) } else { rows }
            case .split:
                HStack(spacing: 0) {
                    if path.isEmpty || proxy.size.width >= configuration.pageHidesSidebarBelow {
                        rows.frame(width: sidebarWidth(in: proxy.size.width))
                        border
                    }
                    pane
                }
            }
        }
        .environment(\.shellLayout, layout)
    }

    private func sidebarWidth(in splitWidth: CGFloat) -> CGFloat {
        let window = ShellConfiguration.windowWidth(fitting: splitWidth, among: windowWidths)
        return configuration.sidebarColumn(in: window)[keyPath: sidebar]
    }

    /// Settings, then a row per package. A phone's package row pushes the package's page.
    private var rows: some View {
        List {
            ShellRow(DemoPage.settings, path: $path) { Text(DemoWords.settings) }
                .listRowBackground(marked(path.contains(.settings)))
            ForEach(DemoPackage.allCases) { package in
                Group {
                    switch layout {
                    case .split:
                        ShellRow(package, picked: $picked, path: $path) { Text(verbatim: package.name) }
                    case .stack:
                        Button {
                            picked = package
                            path = [.package(package)]
                        } label: {
                            Text(verbatim: package.name)
                        }
                    }
                }
                .listRowBackground(marked(path.isEmpty && picked == package))
            }
        }
    }

    /// A split's mark on the row whose page or pick shows.
    private func marked(_ isOpen: Bool) -> Color? {
        layout == .split && isOpen ? Color.accentColor.opacity(0.2) : nil
    }

    @ViewBuilder private var border: some View {
        if let width = configuration.sidebarBorder.drawnWidth(displayScale: displayScale) {
            Rectangle().fill(.separator).frame(width: width)
        }
    }

    @ViewBuilder private var pane: some View {
        if let page = path.last {
            pageView(page)
        } else {
            ShellPane(selection: picked) { Text($0.summary) } empty: {
                Text(DemoWords.prompt).foregroundStyle(.secondary)
            }
        }
    }

    /// The top page, with Back, which closes it.
    private func pageView(_ page: DemoPage) -> some View {
        Group {
            switch page {
            case .settings: Text(DemoWords.settings).font(.title2)
            case .package(let package): Text(package.summary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            Button(DemoWords.back, systemImage: "chevron.backward") { path.removeLast() }
                .padding()
        }
    }
}
