# Containers

The package runs inside the host app's process; its one product is the container an app links.

```mermaid
C4Container
    title FamilyDay products

    Person(maintainer, "1 App maintainer")

    System_Boundary(package, "2 FamilyDay package") {
        Container(day, "3 FamilyDay", "Swift library", "Day key, row, sender apps, day links, row view and chip")
    }

    System_Ext(shell, "4 AdaptiveShell")
    System_Ext(ui, "5 SwiftUI")

    Rel(maintainer, day, "A")
    Rel(day, shell, "B")
    Rel(day, ui, "C")

    UpdateElementStyle(maintainer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(day, $bgColor="#0f766e", $borderColor="#115e59", $fontColor="#ffffff")
    UpdateElementStyle(shell, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
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
| 1   | The maintainer who adds a day to an app. | They link the product. |
| 2   | `Packages/FamilyDay`, with its own manifest. | It builds and tests alone. |
| 3   | The one library an app links for its day. | Every app shares one key and one row. |
| 4   | The package whose `PendingOpen` holds a day link. | Links open the way they already do. |
| 5   | Apple's buttons, labels and `openURL`. | The system routes each link. |
| A   | Links the library and writes its rows with it. | No other setup. |
| B   | Reads day links into the shell's pending open. | A cold launch's day waits for its screen. |
| C   | Draws the row and the chip, and opens their links. | A host or a test can route the links. |
