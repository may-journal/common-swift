import SwiftUI
import Testing
import Theme
import UITestingLibrary

/// Requirement 0005: shared views draw with the tokens the app hands in.
extension ThemeTests {
    @MainActor
    @Suite struct Tokens {
        private func render(
            _ look: Look = .system, @ViewBuilder content: () -> some View
        ) throws -> (Screen, User) {
            let screen = try Screen.render(look: look, content: content)
            return (screen, User(screen))
        }

        @Test func test0005_1() async throws {
            let (screen, user) = try render(Look(appearance: .light)) {
                Badge(name: "Card").theme(Brand.theme)
            }
            try await user.sees(.text("Card accent #4F46E5"))
            try await user.sees(.text("Card gap 14"))
            try await user.sees(.text("Card corner 28"))
            try screen.close()
        }

        @Test func test0005_2() async throws {
            let (screen, user) = try render { Badge(name: "Card") }
            try await user.sees(.text("Card gap 12"))
            try await user.sees(.text("Card corner 20"))
            #if os(macOS)
            try await user.sees(.text("Card body 13"))
            #else
            try await user.sees(.text("Card body 17"))
            #endif
            try screen.close()
        }

        @Test func test0005_3() async throws {
            let (screen, user) = try render(Look(appearance: .dark)) {
                Swatch(name: "Brand", color: Brand.indigo)
            }
            try await user.sees(.text("Brand #8B85F5"))
            try screen.close()
        }

        @Test func test0005_4() async throws {
            let (screen, user) = try render(Look(appearance: .light)) {
                Swatch(name: "Brand", color: Brand.indigo)
            }
            try await user.sees(.text("Brand #4F46E5"))
            try screen.close()
        }

        @Test func test0005_5() async throws {
            let stored = try #require(Color(hex: "#FF5B52"))
            let (screen, user) = try render { Swatch(name: "Tag", color: stored) }
            try await user.sees(.text("Tag #FF5B52"))
            try screen.close()
        }

        @Test func test0005_6() async throws {
            let stored = Color(hex: "#FF5B5") ?? Color(rgb: 0x80_80_80)
            let (screen, user) = try render { Swatch(name: "Tag", color: stored) }
            try await user.sees(.text("Tag #808080"))
            try screen.close()
        }

        @Test func test0005_7() async throws {
            let (screen, user) = try render(Look(appearance: .light)) {
                VStack {
                    Badge(name: "Inner").theme(Theme(spacing: Spacing(medium: 6)))
                    Badge(name: "Outer")
                }
                .theme(Brand.theme)
            }
            try await user.sees(.text("Inner gap 6"))
            try await user.sees(.text("Outer gap 14"))
            try screen.close()
        }
    }
}
