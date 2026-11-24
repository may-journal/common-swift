import AdaptiveShell
import Foundation
import StorybookKit
import SwiftUI

/// AdaptiveShell's links, listed under their requirements. Each page hands `PendingOpen` a link
/// before its pane shows, as a cold launch does, then the pane opens whatever it held.
enum LinksPage {
    @MainActor static var pages: [BookPage] {
        [
            BookPage(title: "0011.1 Cold launch link") {
                LinkSample("\(LinkSample.scheme)://package/\(DemoPackage.storybook.name)")
            },
            BookPage(title: "0011.2 Another app's link") {
                LinkSample("https://example.com/package/\(DemoPackage.storybook.name)")
            }
        ]
    }
}

/// A pane that opens the package a link names, once the link has waited in `PendingOpen`.
private struct LinkSample: View {
    /// The scheme of the demo's own links, such as common-swift-demo://package/Storybook.
    static let scheme = "common-swift-demo"

    @State private var requests: PendingOpen<DemoPackage>
    @State private var picked: DemoPackage?

    init(_ link: String) {
        // The link arrives before the pane exists, so the request waits for it.
        let requests = PendingOpen<DemoPackage>(read: Self.package)
        if let url = URL(string: link) { requests.open(url) }
        _requests = State(initialValue: requests)
    }

    var body: some View {
        ShellPane(selection: picked) { package in
            Text(package.summary)
        } empty: {
            Text(DemoWords.prompt).foregroundStyle(.secondary)
        }
        .opensRequests(requests) { picked = $0 }
    }

    /// The package a demo link names; another app's link names none.
    private static func package(_ link: URL) -> DemoPackage? {
        guard link.scheme == scheme else { return nil }
        return DemoPackage(rawValue: link.lastPathComponent)
    }
}
