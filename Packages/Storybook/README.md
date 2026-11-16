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
- `--storybook` at launch, with an optional page name. `--storybook-device`, `--storybook-orientation`, `--storybook-text-size`, `--storybook-data-length` and `--storybook-freshness on|off` set the header's choices.

## Configure

`StorybookConfiguration` takes the host's words, accessibility identifiers, version string, launch arguments, history and pages of its own. Every field has a default. The words default to this package's String Catalog, so a host passes its own only to match its catalog. Hand-written pages are `BookPage` values, named like previews.

## Badges

Name each page by the requirement acceptance it shows, such as `#Preview("0006.3 unlocked")`. The `swift-storybook-requirements` Fitness check fails a page named any other way. The catalog lists a page under its Swift file's name, with the ID beside its label. An app adopts the badges in four steps:

1. Apply the `StorybookHistory` build plugin to the app target, which needs a Copy Bundle Resources phase, as the XcodeGen sample below spells it.
2. Before each build that needs real ages, run the `StorybookCoverage` command plugin, which writes `docs/requirements/coverage.json` at the repo's root.
3. In a repo with a `Package.swift`, run `swift package --disable-sandbox --allow-writing-to-package-directory storybook-coverage`, since it runs the tests itself.
4. Build in CI with `-skipPackagePluginValidation`, from a full clone: a shallow clone shows no badges.

```yaml
buildToolPlugins:
  - plugin: StorybookHistory
    package: common-swift
```

The map lists the files each acceptance's test covers, running Swift packages through `swift test` and Xcode schemes through `xcodebuild`. An Xcode-only app runs the tool from its resolved checkout, `swift run --package-path <checkout> storybook-coverage --scheme <scheme> --destination <destination>`. Git ignores the map, which goes stale, so release and TestFlight builds run the plugin before archiving, as in Xcode Cloud's `ci_post_clone.sh`. Without the map, or for an acceptance it misses, the test's file dates the badge; one without a test gets none.

The ID chip fades with age; the header's flame button adds a panel with its Then line, age scale and commits since. Previews read the header's data length through `PreviewSample` or `\.previewDataLength`.

## Release builds

Build the host app's Release configuration file by file, not whole module. Whole-module optimization drops the types each `#Preview` declares that nothing else references, and the catalog then lists nothing.

## Develop

```sh
swift test
```

The tests prove requirements 0006 to 0008 in the repo's root [docs/requirements](../../docs/requirements), where Fitness reads them. [docs/architecture](docs/architecture) holds this package's own C4 views.
