# Components

This splits the Storybook library in [02-containers.md](02-containers.md) into its parts.

```mermaid
C4Component
    title Storybook library

    Person(tester, "1 Tester")

    Container_Boundary(core, "2 Storybook") {
        Component(section, "3 Settings section", "SwiftUI", "Version row and Storybook row")
        Component(availability, "4 Availability", "Observation", "Gate answer, tap counter, saved unlock")
        Component(entry, "5 Entry", "SwiftUI", "One cover for the row, shake, shortcut and launch")
        Component(catalog, "6 Catalog", "SwiftUI", "Navigator, grid, page and header toggles")
        Component(settings, "7 Launch settings", "Swift", "Device, text size and data length tables")
    }

    System_Ext(kit, "8 swift-storybook")

    Rel(tester, section, "A")
    Rel(section, availability, "B")
    Rel(entry, availability, "C")
    Rel(entry, catalog, "D")
    Rel(catalog, settings, "E")
    Rel(catalog, kit, "F")

    UpdateElementStyle(tester, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(section, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(availability, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(entry, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(catalog, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(settings, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(kit, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
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
| 1   | The tester from the system context. | They reach the catalog through Settings. |
| 2   | The library an app links. | Every part ships together. |
| 3   | `StorybookSettingsSection`, the one view an app drops into its Form. | Version and Storybook rows stay in step. |
| 4   | `StorybookAvailability`, which the app holds one of. | The row and the cover read one state. |
| 5   | `storybookEntry(_:)` at the app's root. | Two covers can never stack. |
| 6   | The split-view catalog over every page. | Testers browse every state. |
| 7   | The settings each `--storybook-*` argument and header button sets. | A capture can be repeated. |
| 8   | eure's preview finder. | Pages come from `#Preview` blocks. |
| A   | Taps Version seven times, then Storybook. | The switch is hidden from App Review. |
| B   | Counts the taps and reads whether the catalog may open. | The gate decides the build. |
| C   | Waits on the gate's answer, then opens the cover. | No way in reads a stale answer. |
| D   | Shows the catalog, opened at the page a launch named. | Every way in shows the same catalog. |
| E   | Reads the launch arguments once per launch. | A header tap is not undone on redraw. |
| F   | Lists every preview and the app's own pages. | The app keeps no list of previews. |
