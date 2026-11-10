import Navigation
import SwiftUI
import UITestingLibrary

/// The example app's root: one routed stack, which takes each held request once it is ready.
struct DiaryApp: View {
    let diary: Diary

    var body: some View {
        RoutedStack(router: diary.router) {
            VStack {
                Text("Today")
                Button("Settings") { diary.router.show(.settings) }
                Button("Open day") { diary.router.push(.day("2026-11-09")) }
                Button("Back") { diary.router.pop() }
            }
        } destination: { route in
            DiaryPage(diary: diary, route: route)
        }
        .onChange(of: diary.requests.pending, initial: true) {
            if let request = diary.requests.take() { diary.leaving.request(.open(request)) }
        }
        .overlay(alignment: .bottom) {
            if diary.missing != nil { Text("Not Found") }
        }
    }
}

/// The screen behind each route.
struct DiaryPage: View {
    let diary: Diary
    let route: ExampleRoute

    var body: some View {
        switch route {
        case .day(let key):
            VStack {
                Text("Day \(key)")
                Button("Settings") { diary.router.show(.settings) }
                Button("Home") { diary.router.popToRoot() }
            }
        case .settings:
            VStack {
                Text("Preferences")
                Button("Open day") { diary.router.push(.day("2026-11-09")) }
            }
        case .entry:
            EntryPage(diary: diary, leaving: diary.leaving)
        }
    }
}

/// An editing screen whose every exit goes through the leave guard.
struct EntryPage: View {
    let diary: Diary
    let leaving: LeaveGuard<Exit>

    var body: some View {
        VStack {
            Text("Entry")
            if let draft = diary.draft { Text(draft) }
            if diary.saveError != nil { Text("Save failed") }
            Button("Write") { diary.draft = "Lunch by the river" }
            Button("Close") { leaving.request(.back) }
            if leaving.pending != nil {
                Text("Unsaved entry")
                Button("Save") { Task { await diary.saveThenLeave() } }
                Button("Discard") { leaving.discard() }
                Button("Cancel") { leaving.cancel() }
            }
        }
        // The stack's back swipe skips the guard, so it hides while a draft is unsaved.
        .navigationBarBackButtonHidden(diary.draft != nil)
    }
}

/// What a test drives: the app rendered on `diary`, and the user acting on it.
struct Session {
    let screen: Screen
    let user: User

    @MainActor
    init(_ diary: Diary) throws {
        screen = try Screen.render { DiaryApp(diary: diary) }
        user = User(screen)
    }
}
