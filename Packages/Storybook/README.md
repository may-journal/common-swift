# Storybook

The in-app catalog of every SwiftUI `#Preview`, for the may-* apps on iOS and the Mac. It builds on [swift-storybook](https://github.com/eure/swift-storybook). It ships the gate that decides who sees it and the Settings section that opens it.

## Adopt

Depend on common-swift as the [root README](../../README.md#depend-on-it) says, and link the `Storybook` product. Link `StorybookSandbox` as well for the TestFlight rule.

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

An app with a Version row of its own calls `tapsVersion()` from it, adds `StorybookRowSection` instead, and asks `resolve()` as Settings appear.

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

`StorybookConfiguration` takes the host's words, accessibility identifiers, version string, launch arguments, history and pages of its own. Every field has a default. The words default to this package's String Catalog, so a host passes its own only to match its catalog. Hand-written pages are `BookPage` values, named like previews.

## Badges

Name each page by the requirement acceptance it shows, such as `#Preview("0006.3 unlocked")`. The `swift-storybook-requirements` Fitness check fails a page named any other way. The catalog lists a page under its Swift file's name, with the ID beside its label. Apply the `StorybookHistory` plugin to the app target, which needs a Copy Bundle Resources phase, as XcodeGen spells it:

```yaml
buildToolPlugins:
  - plugin: StorybookHistory
    package: common-swift
```

On each build it bundles each acceptance's dates from the git history of `docs/requirements`, and none from a shallow clone. A page's ID chip is its badge, filled in accent color for New and fading with age beside a four-bar meter. Under the label it says New in this build, how long ago it changed, or the day it was added. The page's header places that age on a five-week scale.

Previews read the header's data length through `PreviewSample` or `\.previewDataLength`.

## Release builds

Build the host app's Release configuration file by file, not whole module. Whole-module optimization drops the types each `#Preview` declares that nothing else references, and the catalog then lists nothing.

## Develop

```sh
swift test
```

The tests prove requirements 0006 to 0008 in the repo's root [docs/requirements](../../docs/requirements), where Fitness reads them. [docs/architecture](docs/architecture) holds this package's own C4 views.
