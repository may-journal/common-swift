import AdaptiveShell
import Storybook
import SwiftUI

/// The demo's root, drawn by AdaptiveShell. The packages fill the sidebar, and ShellPane shows the
/// picked one beside it; a phone pushes it over the list instead.
public struct DemoRoot: View {
    private let storybook: StorybookAvailability
    @State private var path: [DemoPage] = []
    @State private var picked: DemoPackage?

    public init(storybook: StorybookAvailability) {
        self.storybook = storybook
    }

    public var body: some View {
        AdaptiveShell(path: $path) { layout in
            packages(layout)
        } pane: {
            ShellPane(selection: picked) { package in
                PackageDetail(package: package, openSettings: openSettings)
            } empty: {
                Text(DemoWords.prompt).foregroundStyle(.secondary)
            }
        } page: { _ in
            Form { StorybookSettingsSection(storybook) }
                .formStyle(.grouped)
                .navigationTitle(DemoWords.settings)
        }
        .storybookEntry(storybook)
    }

    /// The list of packages: the sidebar of a split, or the root of a phone's stack.
    @ViewBuilder
    private func packages(_ layout: ShellLayout) -> some View {
        let list = List(DemoPackage.allCases) { package in
            Button { picked = package } label: {
                VStack(alignment: .leading) {
                    Text(verbatim: package.name).font(.headline)
                    Text(package.summary).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel(package.name)
        }
        .navigationTitle(DemoWords.packages)
        .toolbar {
            Button(DemoWords.settings, systemImage: "gear", action: openSettings)
        }
        if layout == .stack {
            list.navigationDestination(item: $picked) { package in
                PackageDetail(package: package, openSettings: openSettings)
            }
        } else {
            list
        }
    }

    private func openSettings() {
        picked = nil
        path = [.settings]
    }
}

/// What one package shows when picked.
struct PackageDetail: View {
    let package: DemoPackage
    let openSettings: () -> Void
    @Environment(\.shellLayout) private var layout

    var body: some View {
        VStack(spacing: 16) {
            Text(package.summary)
            switch package {
            case .adaptiveShell:
                Text(layout == .split ? DemoWords.inPane : DemoWords.onStack)
            case .storybook:
                Button(DemoWords.openSettings, action: openSettings)
            }
        }
        .padding()
        .navigationTitle(Text(verbatim: package.name))
    }
}
