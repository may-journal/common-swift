import AdaptiveShell
import Foundation
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0011: a link heard before the screen shows waits until it can open.
extension AdaptiveShellTests {
    @MainActor
    @Suite struct Holding {
        /// The diary's links, `diary://entry/<name>`; anything else is not the diary's.
        static func entry(_ link: URL) -> String? {
            link.scheme == "diary" && link.host() == "entry" ? link.lastPathComponent : nil
        }

        /// Renders the screen that opens held entries, after the link arrived.
        static func launch(after link: String) throws -> (Screen, User) {
            let requests = PendingOpen(read: entry)
            requests.open(try #require(URL(string: link)))
            let screen = try Screen.render { Opened(requests: requests) }
            return (screen, User(screen))
        }

        @Test func test0011_1() async throws {
            let (screen, user) = try Self.launch(after: "diary://entry/kites")
            try await user.sees(.text("Opened kites"))
            try screen.close()
        }

        @Test func test0011_2() async throws {
            let (screen, user) = try Self.launch(after: "https://example.com/entry/kites")
            try await user.sees(.text(Opened.nothing))
            try await user.doesNotSee(.text("Opened kites"))
            try screen.close()
        }
    }
}

/// The diary's first screen, which opens a held entry once it shows.
private struct Opened: View {
    let requests: PendingOpen<String>
    @State private var opened: String?

    var body: some View {
        Text(opened.map { "Opened \($0)" } ?? Self.nothing)
            .opensRequests(requests) { opened = $0 }
    }

    static let nothing = "No entry open"
}
