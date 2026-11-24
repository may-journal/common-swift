import Foundation
import Storybook
import StorybookKit
import SwiftUI
import Testing
import UITestingLibrary

/// Requirement 0020: the catalog lists each requirement's pages together, in acceptance order.
extension StorybookTests {
    @MainActor
    @Suite struct Grouping {
        /// Two of requirement 0015's pages, declared in two files, then the diary card's page.
        /// 0015.8's file sorts first, so only acceptance order puts 0015.2 first.
        static var pages: [BookPage] {
            [
                BookPage("StorybookTests/DiaryCard.swift", 9, title: "0015.8 full") { Text("Eight entries") },
                BookPage("StorybookTests/DiaryList.swift", 5, title: "0015.2 empty") { Text("No entries") }
            ] + DiaryApp.pages
        }

        static let changed = "0015 Seeing what changed"

        /// A build's history that holds no acceptance yet, only its docs' titles.
        static var titled: StorybookHistory {
            StorybookHistory(
                commit: "build", buildDate: .now, acceptances: [:],
                requirements: ["0008": "Launch settings", "0015": "Seeing what changed"])
        }

        /// A grid card, which reads its page's label, ID and badge as one button.
        static func card(_ label: String, _ id: String) -> Query {
            .text("\(label), \(id), \(StorybookWords.badge(nil))")
        }

        /// Chooses Next, as ⌘] does on the Mac.
        static func choosesNext(_ launch: Launch) async throws {
            try await launch.user.presses("]", with: [.command])
        }

        @Test func test0020_1() async throws {
            let launch = try Launch(.debug, history: Self.titled, pages: { Self.pages })
            try await launch.opensStorybook()
            try await launch.user.sees(.text(Self.changed))
            try await launch.user.taps(.identifier("storybook.group.0015"))
            try await launch.user.sees(Self.card("empty", "0015.2"))
            try await launch.user.sees(Self.card("full", "0015.8"))
            try launch.quits()
        }

        @Test func test0020_2() async throws {
            let launch = try Launch(.debug, arguments: ["--storybook", "0015.2 empty"], pages: { Self.pages })
            try await launch.user.sees(.text("No entries"))
            try await Self.choosesNext(launch)
            try await launch.user.sees(.text("Eight entries"))
            try launch.quits()
        }

        @Test func test0020_3() async throws {
            let launch = try Launch(
                .debug, arguments: ["--storybook", Self.changed], history: Self.titled, pages: { Self.pages })
            try await launch.user.sees(Self.card("empty", "0015.2"))
            try await launch.user.sees(Self.card("full", "0015.8"))
            try launch.quits()
        }

        @Test func test0020_4() async throws {
            let launch = try Launch(.debug, pages: { Self.pages })
            try await launch.opensStorybook()
            try await launch.user.sees(.text("0008"))
            try await launch.user.sees(.text("0015"))
            try await launch.user.doesNotSee(.text(Self.changed))
            try launch.quits()
        }
    }
}
