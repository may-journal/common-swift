# Containers

The package runs inside the host app's process; its one product is the container an app links.

```mermaid
C4Container
    title AdaptiveShell products

    Person(maintainer, "1 App maintainer")

    System_Boundary(package, "2 AdaptiveShell package") {
        Container(shell, "3 AdaptiveShell", "Swift library", "Shell, split, configuration and pending open")
    }

    System_Ext(ui, "4 SwiftUI")

    Rel(maintainer, shell, "A")
    Rel(shell, ui, "B")

    UpdateElementStyle(maintainer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(shell, $bgColor="#0f766e", $borderColor="#115e59", $fontColor="#ffffff")
    UpdateElementStyle(ui, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

```mermaid
C4Container
    title Legend

    Person(p, "Person", "Human actor")
    System_Boundary(b, "Boundary") {
        Container(c, "Container", "Tech", "Runs on its own")
    }
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(c, $bgColor="#0f766e", $borderColor="#115e59", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The maintainer who adds the shell to an app. | They link the product. |
| 2   | `Packages/AdaptiveShell`, with its own manifest. | It builds and tests alone. |
| 3   | The one library an app links for its root. | It needs nothing beyond SwiftUI. |
| 4   | Apple's stacks, split view and toolbars. | The shell arranges them. |
| A   | Links the library and builds its root with it. | No other setup. |
| B   | Draws a stack or a split with the rail's toggle. | The system draws each platform's chrome. |
