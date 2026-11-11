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
