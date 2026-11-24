# FamilyDay

The day every may-* app keys its part of a day by, and the one row it writes into that day. A row and the day chip each open an app at that day, through AdaptiveShell's `PendingOpen`. May Calendar's timeline gathers the rows, and each sibling shows the chip to get back.

## Adopt

Depend on common-swift as the [root README](../../README.md#depend-on-it) says, and link the `FamilyDay` product.

```swift
import AdaptiveShell
import FamilyDay

let day = DayKey(photo.creationDate)            // "2026-12-12", as Captions' day line keys it
let row = DayRow(
    sender: .captions, day: day, title: "Jo found the last good squash",
    kicker: "4 photos, 3 with words", item: photo.localIdentifier)

DayRowView(row)     // a tap opens Captions at that day, and at the photo
DayChip(day)        // a tap returns to that day in May Calendar
```

- `DayKey` reads and writes "2026-12-12", and is `Codable` in that form.
- `DayKey(_:timeZone:)` keys a date as Captions' `DayLine.dayKey` does, always in the Gregorian calendar.
- `DayRow` holds the sender, a one-line title, a kicker and the `DayLink` that opens the sender.
- `FamilyApp` names each sender, its home screen name and the URL scheme it answers.
- `DayLink` is `<scheme>://day/2026-12-12`, with `?item=<id>` when the app names one thing.
- `DayRowView` and `DayChip` open links through the environment's `openURL`, so a host or a test can route them.

## Open a day

Each app holds the day links it answers in a `PendingOpen`, as AdaptiveShell's [Links](../AdaptiveShell/README.md#links) section says. Another app's link opens nothing.

```swift
let days = PendingOpen(app: .captions)

LibraryView().opensRequests(days) { coordinator.open($0.day, item: $0.item) }
```

Out of a Hat, May Journals and PhotoPortal already register their schemes. May Calendar, List Total and Captions register `maycalendar`, `listtotal` and `mayphotos` when they adopt a day.

## Roll out

Writing rows into May Calendar's timeline, and each app's own row, follow in each app's repo.

## Develop

```sh
swift test
```

The tests prove requirement 0019 in the repo's root [docs/requirements](../../docs/requirements), where Fitness reads it; the demo's tests prove its catalog rows. A Mac test window has no URL routing, so each test hands the links to the apps' `PendingOpen` through `openURL`. [docs/architecture](docs/architecture) holds this package's own C4 views.
