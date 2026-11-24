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

## Catalog

The sidebar holds one group per requirement, titled by its doc's number and title, such as `0006 Seeing the Storybook row`. Its pages sit in acceptance order, so `0002.10` follows `0002.9`, whichever files declare them. The groups sort by number. The `StorybookHistory` plugin bundles the titles; a build without them titles each group by its number alone.

A page named by no acceptance sits under its name before ": ", else its Swift file's name, after every requirement. Search matches a group's title, or a page's name or file. `--storybook` with a group's number or title opens its pages side by side.

## Badges

Name each page by the requirement acceptance it shows, such as `#Preview("0006.3 unlocked")`. The `swift-storybook-requirements` Fitness check fails a page named any other way. The [catalog](#catalog) lists the page under its requirement, with the ID beside its label. An app adopts the badges in four steps:

1. Apply the `StorybookHistory` build plugin to the app target, which needs a Copy Bundle Resources phase, as the XcodeGen sample below spells it.
2. Run the [coverage step](#coverage-step) before each build that needs real ages; it writes `docs/requirements/coverage.json` at the repo's root, which git must ignore.
3. In a repo with a `Package.swift`, run `swift package --disable-sandbox --allow-writing-to-package-directory storybook-coverage` instead, since it runs the tests itself.
4. Build in CI with `-skipPackagePluginValidation`, from a full clone: a shallow clone shows no badges.

```yaml
buildToolPlugins:
  - plugin: StorybookHistory
    package: common-swift
```

The ID chip fades with age; the header's flame button adds a panel with its Then line, age scale and commits since. Previews read the header's data length through `PreviewSample` or `\.previewDataLength`.

## Coverage step

The map lists the files each acceptance's test covers, running Swift packages through `swift test` and Xcode schemes through `xcodebuild`. An Xcode-only app runs the tool from its resolved common-swift checkout, so the tool matches the plugin. One `make coverage` does it, and the run, device and archive targets list it first:

```make
CHECKOUT = $(DERIVED_DATA)/SourcePackages/checkouts/common-swift
coverage: generate
	xcodebuild -resolvePackageDependencies -project $(PROJECT) -scheme $(SCHEME) \
		-derivedDataPath $(DERIVED_DATA) -skipPackagePluginValidation -quiet
	swift run --package-path $(CHECKOUT) -q storybook-coverage --xcode $(PROJECT) --scheme $(SCHEME) \
		--destination 'platform=macOS,variant=Designed for iPad' -- -allowProvisioningUpdates
```

Arguments after `--` go to each `xcodebuild` call, such as `-xcconfig <file>` or `DEVELOPMENT_TEAM=<team>`. The tool skips the run when the map was written for HEAD with the same arguments on a clean tree. An untracked file counts as a change, but an ignored one, such as an xcconfig, does not: delete the map after changing it. Without the map, or for an acceptance it misses, the test's file dates the badge; one without a test gets none.

### One run

Put `.storybookCoverage` on each test target's root suite, from the `StorybookCoverageScope` product, which depends on nothing. The tool then runs each suite once instead of once per test. A target with only XCTest names `StorybookCoverageObserver` as its bundle's `NSPrincipalClass` instead. Both act only in the tool's run, which sets `TEST_RUNNER_STORYBOOK_COVERAGE=1`.

```swift
import StorybookCoverageScope
import Testing

@Suite(.serialized, .storybookCoverage) struct DiaryTests {}
```

Before each test the scope zeroes every loaded image's coverage counters, then attaches the test's raw profile. The tool converts each with `llvm-profdata` and `llvm-cov`, adding the first test's launch profile to every test. A test without a profile runs alone: one outside the trait, one that failed, or every test if the profile internals change. A `static let` counts only for the first test that touches it, and work a test leaves running counts for the next.

A test with arguments, such as `test0048_5(story:)`, maps to the files all its cases cover. Xcode names it with its argument labels, and the tool matches it by the name before them.

### Later commits

On a later commit the tool maps again only the acceptances whose covered files, test files or requirement docs changed. It maps every acceptance when the stamp is missing, as after a run on a dirty tree, or not in HEAD's history. A changed argument, project, package, xcconfig, `Info.plist` or entitlements file does the same. So does a changed code or resource file no row lists.

A change to over 60% of acceptances maps them all too. So does `--full`, which a nightly run uses to clear rows a partial run kept. Go requirement tests run one at a time. In a module with nothing but tests, they map to their own files without a run.

## Catalog files

The coverage map leaves out the catalog's own files, since a test opening the catalog covers every page. A catalog file imports `Storybook`, names a `BookPage` or the `StorybookConfiguration`, and declares no view, app or scene. A folder of mostly catalog files goes whole, helpers included. So screens stay, even those holding their own page or a `#Preview`.

Pass `--exclude <folder or file>` from the repo's root, as often as needed, for a helper the rule misses. `--results <folder>` maps an earlier Xcode run's result bundles again; a test without one maps to its own file.

## Release builds

Build the host app's Release configuration file by file, not whole module. Whole-module optimization drops the types each `#Preview` declares that nothing else references, and the catalog then lists nothing.

## Develop

```sh
swift test
```

The tests prove requirements 0006 to 0008, 0015 to 0018 and 0020 in the repo's root [docs/requirements](../../docs/requirements), where Fitness reads them. [docs/architecture](docs/architecture) holds this package's own C4 views.
