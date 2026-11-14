# common-swift
Shared Swift packages for the may-* iOS apps

## Depend on it

An app depends on the whole repo by URL, and picks only the products it uses. SwiftPM reads only the root `Package.swift`, which lists each package's products by path. One version tag releases every package.

```swift
.package(url: "https://github.com/may-journal/common-swift", from: "1.0.0")
```

In an XcodeGen `project.yml`, name the repo under `packages` and each product under the target's `dependencies`, with `package: common-swift`. A product links only what it names, so an app that skips a product never links its frameworks. Each package's README under `Packages/` lists its products.

## Develop

Each folder under `Packages/` keeps its own `Package.swift`, README and tests, and builds alone with `swift test` in that folder. A new package adds its products and targets to the root `Package.swift` by `path:` as well.

## Demo app

[Examples/CommonSwiftDemo](Examples/CommonSwiftDemo) shows every package at work, on an iPhone, an iPad and the Mac. AdaptiveShell draws its root, with the packages in the sidebar. ShellPane shows the picked one beside them, and a phone pushes it over the list. It hosts the Storybook package rather than replacing it: Settings holds the Storybook row, and the catalog lists a page per package.

Its screens live in the DemoKit package beside the app, which links this repo by path. `make demo-test` runs its requirement tests on the Mac. `make demo` builds the app with no signing credentials, and `make demo-install DEVICE=<udid>` runs it on a paired device.

The demo signs with the owner's team and bundle ID, so a fork sets its own `DEVELOPMENT_TEAM` and `bundleIdPrefix` in [project.yml](Examples/CommonSwiftDemo/project.yml).
