# common-swift

Shared Swift packages for the may-* iOS apps: may-calendar, may-journals and may-photos. Each package holds one pattern those apps grew on their own, written once here.

## Layout

One Swift package at the root, one library product per package, and one target behind each product.

```text
Package.swift              one .library product per package
Sources/<Name>/            the package's code; the module is <Name>
Tests/<Name>Tests/         its requirement tests, one per acceptance
docs/requirements/         the acceptances each test proves
docs/architecture/         the design views
changelog/                 one entry file per change
```

Targets never depend on each other unless the dependency is stated in `Package.swift`. An app that imports `Navigation` compiles and links only `Navigation`.

## Packages

- `Navigation`: a router for a stack's path, deep-link tables, cold-launch requests and a guard for unsaved work. See [Navigation lessons](docs/architecture/navigation-lessons.md).
- `Theme`: the app's colors, type scale, spacing and radii, handed to shared views through the environment. See [Theme lessons](docs/architecture/theme-lessons.md).

## Using a package in an app

Add the repository once, then link only the products the app imports. In an XcodeGen `project.yml`:

```yaml
packages:
  CommonSwift:
    url: https://github.com/may-journal/common-swift
    majorVersion: 1.0.0
targets:
  MayPhotos:
    dependencies:
      - package: CommonSwift
        product: Navigation
```

In another `Package.swift`, use `.product(name: "Navigation", package: "common-swift")`. The repository is private, so the build machine needs GitHub access to may-journal, as Xcode Cloud already has for the apps.

## Adding a package

1. Add `.library(name: "<Name>", targets: ["<Name>"])`, a `.target(name: "<Name>")` and a `.testTarget(name: "<Name>Tests", dependencies: ["<Name>"])` to `Package.swift`.
1. Put the code in `Sources/<Name>/` and the tests in `Tests/<Name>Tests/`.
1. Write its acceptances in `docs/requirements/` from [the template](docs/requirements/template.md). Each acceptance has one test named `testNNNN_N`.
1. Record what the apps taught you in `docs/architecture/<name>-lessons.md`, and list the package above.
1. Add a changelog entry file and run `make requirements`.

## Tasks

Run `make requirements` for the tests, `make format` to wrap lines, and `make fitness` for the full suite CI runs.
