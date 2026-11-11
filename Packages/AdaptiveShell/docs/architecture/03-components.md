# Components

This splits the AdaptiveShell library in [02-containers.md](02-containers.md) into its parts.

```mermaid
C4Component
    title AdaptiveShell library

    Person(person, "1 App user")

    Container_Boundary(shell, "2 AdaptiveShell") {
        Component(root, "3 Shell", "SwiftUI", "Picks the stack or the split from the size class")
        Component(split, "4 Split", "SwiftUI", "Sidebar column, pane stack, rail toggle")
        Component(config, "5 Configuration", "Swift", "Column widths, float width and words")
        Component(pending, "6 Pending open", "Observation", "Held request and the modifier that opens it")
    }

    Rel(person, root, "A")
    Rel(root, split, "B")
    Rel(split, config, "C")
    Rel(person, pending, "D")

    UpdateElementStyle(person, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(root, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(split, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(config, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(pending, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
```

```mermaid
C4Component
    title Legend

    Person(p, "Person", "Human actor")
    Container_Boundary(b, "Boundary") {
        Component(c, "Component", "Tech", "A part of the library")
    }

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(c, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The person using the app. | They open pages and links. |
| 2   | The AdaptiveShell library. | One product holds every part. |
| 3   | `AdaptiveShell` and `ShellLayout`. | A compact width stacks; any other splits. |
| 4   | `ShellSplit`, which a Mac-only app may use alone. | The wide layout keeps the pane's own stack. |
| 5   | `ShellConfiguration` and `ShellWords`. | A host matches its sizes and catalog. |
| 6   | `PendingOpen` and `opensRequests(_:perform:)`. | A cold launch's link waits for its screen. |
| A   | Opens a page from the sidebar. | The page lands where the screen has room. |
| B   | Hands the wide layout its views and path. | Both layouts share one path. |
| C   | Reads the widths and the toggle's words. | Defaults need no setup. |
| D   | Taps a link that launches the app. | The request opens once the screen shows. |
