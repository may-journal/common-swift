# AdaptiveShell

The root an app draws its sidebar, pane and pages in, lifted from may-photos. A phone stacks pages over the sidebar. An iPad and the Mac split the sidebar beside a pane with its own stack of pages. It also holds a link heard on a cold launch until the app can open it.

## Adopt

Depend on common-swift as the [root README](../../README.md#depend-on-it) says, and link the `AdaptiveShell` product.

```swift
import AdaptiveShell

AdaptiveShell(path: $state.pages) { layout in
    EntryList()
} pane: {
    EntryDetail()
} page: { page in
    PageView(page)
}
```

The path is the app's own `[Page]`, of any `Hashable` route type, so a view rebuilding never drops an open page. On a phone the sidebar's content is the stack's root. On a wide screen pages open in the pane, and Back shows the pane as it was.

- `sidebar` is told its `ShellLayout`. Add what only the phone's stack needs there, such as a detail pushed with `navigationDestination(item:)`.
- Views inside read `\.shellLayout` to tell a pane beside the sidebar from a phone's stack.
- `ShellLayout.fitting(_:)` is the rule the shell uses, for a modifier the app adds only where it splits.
- An app with no sidebar yet picks the stack-only shell, `AdaptiveShell(path:root:page:)`, on every screen.
- Read state that changes often in the sidebar, pane or page views. Read in the shell's host, it redraws the whole shell.
- A Mac-only app may use `ShellSplit` alone.

## Split

On iOS the system's sidebar toggle moves to the rail on the right, labelled Show Sidebar and Hide Sidebar. The Mac keeps its window toolbar's own toggle. Below `sidebarFloatsBelow`, 800 points by default, the sidebar floats over the pane. There an opened page moves it aside, and closing the page brings it back.

`ShellConfiguration` takes the sidebar's column widths, that width and the toggle's words. Every field has a default; the words come from this package's String Catalog.

## Links

`PendingOpen` reads each link into the app's own request type and holds it. `opensRequests(_:perform:)` takes the links the system opens and hands each held request over once. Put it on the window's root view, which hears links from launch.

```swift
let requests = PendingOpen<OpenDay>(read: OpenDay.init(link:))

LibraryView().opensRequests(requests) { coordinator.open($0) }
```

A widget or an App Intent may set `pending` or call `open(_:)` before the screen exists. The screen opens it once it shows.

## Roll out

- may-photos draws its library with the split shell and holds widget links in `PendingOpen`.
- may-calendar keeps one stack of `HistoryRoute` in `RootLayout`. It takes the stack-only shell with that path, then the split for a pane.
- secret-gifts runs on iPhone only. It takes the stack-only shell with `AppRouter.path`, and `PendingOpen` for links that arrive early.

## Develop

```sh
swift test
```

The tests prove requirements 0010 and 0011 in the repo's root [docs/requirements](../../docs/requirements), where Fitness reads them. A Mac test window has no size class, so the tests give it the phone's or the iPad's. [docs/architecture](docs/architecture) holds this package's own C4 views.
