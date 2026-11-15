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
        } page: { page in
            switch page {
            case .package(let package):
                PackageDetail(package: package, openSettings: openSettings)
            case .settings:
                Form { StorybookSettingsSection(storybook) }
                    .formStyle(.grouped)
                    .navigationTitle(DemoWords.settings)
            }
        }
        .storybookEntry(storybook)
    }

    /// The list of packages: the sidebar of a split, or the root of a phone's stack.
    private func packages(_ layout: ShellLayout) -> some View {
        List(DemoPackage.allCases) { package in
            row(package, layout) {
                VStack(alignment: .leading) {
                    Text(verbatim: package.name).font(.headline)
                    Text(package.summary).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel(package.name)
            .accessibilityHint(package.summary)
            .accessibilityIdentifier(package.rowIdentifier)
            .listRowBackground(
                layout == .split && shown == package ? Color.accentColor.opacity(0.2) : nil)
        }
        .navigationTitle(DemoWords.packages)
        .toolbar {
            Button(DemoWords.settings, systemImage: "gear", action: openSettings)
        }
    }

    /// The package the pane shows, whose row is marked.
    private var shown: DemoPackage? { path.isEmpty ? picked : nil }

    /// A split's row toggles the package in the pane. A phone pushes the package on the same
    /// path as Settings instead, so one stack holds both.
    @ViewBuilder private func row(
        _ package: DemoPackage, _ layout: ShellLayout, @ViewBuilder label: () -> some View
    ) -> some View {
        switch layout {
        case .split: ShellRow(package, picked: $picked, path: $path, label: label)
        case .stack: ShellRow(.package(package), path: $path, label: label)
        }
    }

    /// Settings opens over the pane and keeps the pick, so Back shows it again.
    private func openSettings() {
        if path.last != .settings { path.append(.settings) }
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
