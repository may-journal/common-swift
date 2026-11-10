# System Context

```mermaid
C4Context
    title common-swift

    Person(developer, "1 Developer")
    Person(user, "2 User")
    System(common, "3 common-swift", "Swift packages, one product per shared pattern.")
    System_Ext(apps, "4 may-* apps")
    System_Ext(system, "5 System links")

    Rel(developer, apps, "A")
    Rel(user, apps, "B")
    Rel(apps, common, "C")
    Rel(system, apps, "D")

    UpdateElementStyle(developer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(user, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(common, $bgColor="#1d4ed8", $borderColor="#1e3a8a", $fontColor="#ffffff")
    UpdateElementStyle(apps, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(system, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

```mermaid
C4Context
    title Legend

    Person(p, "Person", "Human actor")
    System(s, "System", "Software we own")
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(s, $bgColor="#1d4ed8", $borderColor="#1e3a8a", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | Builds a may-* app and links the products it needs. | Each app keeps its own routes and screens. |
| 2   | Moves between screens, opens links and writes drafts. | The packages serve what the user does. |
| 3   | This repository: one Swift package with one library product per pattern. | A pattern is written once, not once per app. |
| 4   | may-calendar, may-journals and may-photos. | They grew the patterns the packages keep. |
| 5   | Share links, widget taps and handoff, delivered through `onOpenURL`. | A link can arrive before the app is ready. |
| A   | Defines the app's routes and binds its stacks. | The app owns what its screens are. |
| B   | Taps, swipes and opens links. | Every move goes through one router. |
| C   | Links only the products it imports. | An app pays only for what it uses. |
| D   | Opens the app at a link. | The app parses it through a table. |
