import AdaptiveShell
import Storybook
import SwiftUI

/// The demo's window: its one Storybook availability, and the root drawn with it. Launch with
/// `--demo-package <name>` to open that package straight away.
public struct DemoWindow: View {
    @State private var storybook = StorybookAvailability(
        gate: .debugOnly, configuration: DemoStorybook.configuration())

    public init() {}

    public var body: some View {
        DemoRoot(storybook: storybook, opening: DemoPackage(arguments: ProcessInfo.processInfo.arguments))
    }
}

/// The demo's root, drawn by AdaptiveShell with the packages in the sidebar. Picking one opens the
/// package itself at work: the diary drawn by AdaptiveShell, or the Storybook catalog.
public struct DemoRoot: View {
    private let storybook: StorybookAvailability
    private let opening: DemoPackage?
    @State private var path: [DemoPage] = []
    @State private var picked: DemoPackage?
    @State private var isShellSampleOpen = false

    public init(storybook: StorybookAvailability, opening: DemoPackage? = nil) {
        self.storybook = storybook
        self.opening = opening
    }

    public var body: some View {
        AdaptiveShell(path: $path) { _ in
            packages
        } pane: {
            ShellPane(selection: picked) { package in
                PackageDetail(package: package) { open(package) }
            } empty: {
                Text(DemoWords.prompt).foregroundStyle(.secondary)
            }
        } page: { _ in
            Form { StorybookSettingsSection(storybook) }
                .formStyle(.grouped)
                .navigationTitle(DemoWords.settings)
        }
        .demoCover(isPresented: $isShellSampleOpen) {
            ShellSample { isShellSampleOpen = false }
        }
        .storybookEntry(storybook)
        .task {
            if let opening { open(opening) }
        }
    }

    /// The list of packages, which marks the one picked last.
    private var packages: some View {
        List(DemoPackage.allCases) { package in
            let isPicked = picked == package
            Button { open(package) } label: { PackageRow(package: package) }
                .accessibilityLabel(package.name)
                .accessibilityHint(package.summary)
                .accessibilityAddTraits(isPicked ? .isSelected : [])
                .listRowBackground(isPicked ? Color.accentColor.opacity(0.2) : nil)
        }
        .navigationTitle(DemoWords.packages)
        .toolbar {
            Button(DemoWords.settings, systemImage: "gear") { path = [.settings] }
        }
    }

    /// Opens the package itself over the demo, and marks it in the list.
    private func open(_ package: DemoPackage) {
        picked = package
        path = []
        switch package {
        case .adaptiveShell: isShellSampleOpen = true
        case .storybook: storybook.presentsCatalog()
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

/// The pane after a package closes: its summary, and a button that opens it again.
struct PackageDetail: View {
    let package: DemoPackage
    let open: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(package.summary)
            Button(DemoWords.openAgain, action: open)
        }
        .padding()
        .navigationTitle(Text(verbatim: package.name))
    }
}
