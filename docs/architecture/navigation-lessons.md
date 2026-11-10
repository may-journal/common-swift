# Navigation lessons

What may-calendar, may-journals and may-photos learned about navigation, and where `Navigation` keeps each lesson. Paths are on each app's `main` as of 2026-11-09.

## One route type per stack

Every app names its screens in one `Hashable` enum and pushes values, never views.

- may-calendar: `HistoryRoute` in `src/Models/HistoryRoute.swift` covers Histories, Settings and each Settings page.
- may-journals: `JournalRoute` in `src/Models/JournalRoute.swift` covers every screen and doubles as the share link.
- may-photos: `BrowseState.Page` in `src/ViewModels/BrowseState.swift` covers Search, Settings and Mentions.

`Navigation` keeps this as the `Route` parameter of `Router`.

## The path lives in a model, not a view

may-photos lost pushed pages whenever the grid redrew, until the path moved onto `BrowseState`. may-calendar keeps one `[HistoryRoute]` path at the root and declares one `navigationDestination` there, in `src/UI/Platform/RootLayout.swift`.

`Router` owns the path, and `RoutedStack` declares the one destination at the stack's root.

## Bring a screen to the front, never twice

may-calendar's Settings gear pops back to an open Settings rather than pushing a second copy, in `openSettings()` of `src/UI/RootViewScreens.swift`. A date link there clears the path and goes home.

`Router.show` and `Router.popToRoot` keep both moves.

## Links parse through a table

may-journals reads links in `src/Engine/Navigation/DeepLinkParser.swift` with one small parser per host, which keeps each under the complexity limit. The route prints its own link, so incoming and share links never drift apart.

may-photos does the same for widget taps with `OpenDay` in `src/Shared/OpenDay.swift`.

`DeepLinkTable` and `Linkable` keep both halves.

## A link to deleted content says so

may-journals checks that a route's record still exists before showing it, in `src/ViewModels/NavigationCoordinator.swift`. A missing record shows a "Not Found" sheet, never a blank screen.

`Router.resolve` answers `.notFound` and leaves the stack alone. An editing screen sends `.opened` through its `LeaveGuard`.

## A cold launch hears the link early

may-photos hears a widget tap before its library loads, so `OpenRequests` in `src/ViewModels/OpenRequests.swift` holds it. The grid takes it once it is ready.

`PendingOpen` keeps this hand-off.

## One gate for every exit with unsaved work

may-photos sends every way out of a photo through one guard, in `src/ViewModels/DetailNavigator+LeaveGuard.swift`. With an unsaved caption it parks the request and asks Save, Discard or Cancel. Save leaves only once the caption really saved.

`LeaveGuard` keeps the gate for any editing screen.

## Lessons kept as notes, not code

- A zoom transition does not always clear a `navigationDestination(item:)` binding. may-photos clears it in `onDisappear`.
- Present every sheet from the root through one optional item, as may-calendar does for notes, so two sheets never race.
- Switch top-level surfaces by replacing the stack, not by a modal, as may-journals' `AppShell` does.
