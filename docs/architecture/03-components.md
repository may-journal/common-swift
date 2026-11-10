# Components

This splits the libraries in [02-containers.md](02-containers.md) into packages. Each package is one target behind one product, so an app imports it alone.

```mermaid
C4Component
    title common-swift

    Person(developer, "1 Developer")

    Container_Boundary(repo, "2 common-swift") {
        Component(navigation, "3 Navigation", "Swift", "Sources/Navigation")
        Component(tests, "4 NavigationTests", "Swift", "Tests/NavigationTests")
        Component(manifest, "5 Package manifest", "Swift", "Package.swift")
        Component(theme, "7 Theme", "Swift", "Sources/Theme")
        Component(themeTests, "8 ThemeTests", "Swift", "Tests/ThemeTests")
        Component(states, "9 ScreenStates", "Swift", "Sources/ScreenStates")
        Component(statesTests, "10 ScreenStatesTests", "Swift", "Tests/ScreenStatesTests")
    }

    System_Ext(library, "6 apple-ui-testing-library")

    Rel(developer, navigation, "A")
    Rel(tests, navigation, "B")
    Rel(tests, library, "C")
    Rel(manifest, navigation, "D")
    Rel(developer, theme, "E")
    Rel(themeTests, theme, "F")
    Rel(states, theme, "G")
    Rel(statesTests, states, "H")

    UpdateElementStyle(developer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(navigation, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(tests, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(manifest, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(theme, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(themeTests, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(states, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(statesTests, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(library, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

```mermaid
C4Component
    title Legend

    Person(p, "Person", "Human actor")
    Container_Boundary(cb, "Container boundary") {
        Component(c, "Component", "Tech", "Logical unit")
    }
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(c, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The developer who imports a package. | Each app picks its products. |
| 2   | The repository's one Swift package. | One manifest keeps versions in step. |
| 3   | The `Navigation` product: router, link table, held requests and leave guard. | The apps each grew these on their own. |
| 4   | Requirement tests that render an example app. | Each acceptance has one test. |
| 5   | `Package.swift`, which names each product and the platforms. | It states Swift 6, iOS 27 and macOS 27. |
| 6   | Renders a screen and acts as a person would. | Tests drive the package the way an app uses it. |
| 7   | The `Theme` product: palette roles, type scale, spacing and radii. | Shared views draw in the app's tokens. |
| 8   | Requirement tests that render themed views. | Each acceptance has one test. |
| 9   | The `ScreenStates` product: loading, empty and failed screens, a placeholder and a pill. | Every loading screen says where it stands. |
| 10  | Requirement tests that render a list screen in each state. | Each acceptance has one test. |
| A   | Imports `Navigation` and binds a stack. | The app keeps its own routes. |
| B   | Drives the package through an example app. | Tests use only the public surface. |
| C   | Renders the example app and taps it. | Test targets only; apps never ship it. |
| D   | Builds the library from its sources. | One product per target. |
| E   | Sets its theme once at the root. | No shared view names an app color. |
| F   | Renders views in each appearance and reads their colors. | Tests use only the public surface. |
| G   | Reads colors, sizes and radii from the theme. | It names no app color. |
| H   | Renders a list screen and taps Try Again. | Tests use only the public surface. |
