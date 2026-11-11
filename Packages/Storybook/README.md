# Storybook

The in-app catalog of every SwiftUI `#Preview`, for the may-* apps on iOS and the Mac. It builds on [swift-storybook](https://github.com/eure/swift-storybook). It ships the gate that decides who sees it and the Settings section that opens it.

## Adopt

Add the package by path or by the repo's release tag, and link the `Storybook` product. Link `StorybookSandbox` as well for the TestFlight rule.

```swift
import Storybook
import StorybookSandbox

let storybook = StorybookAvailability(gate: .debugOrSandbox)

WindowGroup { RootView().storybookEntry(storybook) }

Form {
    // the app's own sections
    StorybookSettingsSection(storybook)
}
```

The app holds one `StorybookAvailability` and hands it to both. `storybookEntry(_:)` holds the one cover every way in opens, so put it on one window's root only. `StorybookSettingsSection` is the version row and the Storybook row.

## Gate

- `.debugOnly` is the default, so adopting the package never ships the catalog by accident.
- `.debugOrSandbox` comes from `StorybookSandbox`, the only product that links StoreKit. It adds TestFlight and App Review, the App Store's sandbox.
- `StorybookGate(isDebug:allows:)` builds any other rule.

Where the gate allows the build, seven taps or clicks on Version turn on a hidden switch, kept in user defaults. Debug builds start unlocked.

## Ways in

- The Storybook row at the end of Settings.
- A shake on iOS, through a `UIWindow` extension.
- ⌥⌘⇧D on the Mac, where there is no shake.
- `--storybook` at launch, with an optional page name. `--storybook-device`, `--storybook-orientation`, `--storybook-text-size` and `--storybook-data-length` set the header's choices.

## Configure

`StorybookConfiguration` takes the host's words, accessibility identifiers, version string, launch arguments and pages of its own. Every field has a default. The words default to this package's String Catalog, so a host passes its own only to match its catalog. Hand-written pages are `BookPage` values; a title such as `"DiaryCard: empty"` lists the page under DiaryCard.

Previews read the header's data length through `PreviewSample` or `\.previewDataLength`.

## Release builds

Build the host app's Release configuration file by file, not whole module. Whole-module optimization drops the types each `#Preview` declares that nothing else references, and the catalog then lists nothing.

## Develop

```sh
swift test
```

The tests prove requirements 0006 to 0008 in the repo's root [docs/requirements](../../docs/requirements), where Fitness reads them. [docs/architecture](docs/architecture) holds this package's own C4 views.
