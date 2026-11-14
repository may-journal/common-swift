import AdaptiveShell
import Storybook
import SwiftUI

/// The demo's window: its one Storybook availability, and the root drawn with it.
public struct DemoWindow: View {
    @State private var storybook = StorybookAvailability(
        gate: .debugOnly, configuration: DemoStorybook.configuration())

    public init() {}

    public var body: some View {
        DemoRoot(storybook: storybook)
    }
}

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
                PackageDetail(package: package) { openSettings(.split) }
            } empty: {
                Text(DemoWords.prompt).foregroundStyle(.secondary)
            }
        } page: { page in
            switch page {
            case .package(let package):
                PackageDetail(package: package) { openSettings(.stack) }
            case .settings:
                Form { StorybookSettingsSection(storybook) }
                    .formStyle(.grouped)
                    .navigationTitle(DemoWords.settings)
            }
        }
        .storybookEntry(storybook)
    }

    /// The list of packages: the sidebar of a split, which marks the picked one, or the root of a
    /// phone's stack.
    @ViewBuilder
    private func packages(_ layout: ShellLayout) -> some View {
        List(DemoPackage.allCases) { package in
            let isPicked = layout == .split && picked == package
            Button { pick(package, layout) } label: { PackageRow(package: package) }
                .accessibilityLabel(package.name)
                .accessibilityHint(package.summary)
                .accessibilityAddTraits(isPicked ? .isSelected : [])
                .listRowBackground(isPicked ? Color.accentColor.opacity(0.2) : nil)
        }
        .navigationTitle(DemoWords.packages)
        .toolbar {
            Button(DemoWords.settings, systemImage: "gear") { openSettings(layout) }
        }
    }

    /// A phone pushes the package; a split shows it in the pane, closing an open page first.
    private func pick(_ package: DemoPackage, _ layout: ShellLayout) {
        if layout == .stack {
            path.append(.package(package))
        } else {
            picked = package
            path = []
        }
    }

    /// Opens Settings over what shows now, so Back returns to it.
    private func openSettings(_ layout: ShellLayout) {
        if layout == .stack {
            path.append(.settings)
        } else {
            path = [.settings]
        }
    }
}

/// A package's row: its name over its summary. VoiceOver reads the name, then the summary as
/// the hint.
struct PackageRow: View {
    let package: DemoPackage

    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: package.name).font(.headline)
            Text(package.summary).font(.subheadline).foregroundStyle(.secondary)
        }
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
