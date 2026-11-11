# System Context

Who uses the Storybook package and what it talks to.

```mermaid
C4Context
    title Storybook package

    Person(maintainer, "1 App maintainer")
    Person(tester, "2 Tester")
    System(storybook, "3 Storybook", "The in-app catalog of every preview, its gate and its Settings section.")
    System_Ext(app, "4 may-* app")
    System_Ext(kit, "5 swift-storybook")
    System_Ext(store, "6 App Store")

    Rel(maintainer, app, "A")
    Rel(app, storybook, "B")
    Rel(tester, app, "C")
    Rel(storybook, kit, "D")
    Rel(storybook, store, "E")

    UpdateElementStyle(maintainer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(tester, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(storybook, $bgColor="#1d4ed8", $borderColor="#1e3a8a", $fontColor="#ffffff")
    UpdateElementStyle(app, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(kit, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(store, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
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
| 1   | The developer who adds Storybook to a may-* app. | They add the package and choose its gate. |
| 2   | A person who checks a TestFlight or Debug build. | They open the catalog to see every state. |
| 3   | This package. | The catalog is written once for every app. |
| 4   | The app that links the package. | It holds one availability object. |
| 5   | eure's library that finds every `#Preview`. | The catalog lists what it finds. |
| 6   | Says whether a build came from TestFlight or the App Store. | Only the sandbox gate asks it. |
| A   | Adds the entry, the Settings section and pages of its own. | One modifier and one view adopt it. |
| B   | Hands over its gate, labels, version and pages. | The host owns its words. |
| C   | Taps Version, the Storybook row, or shakes the phone. | Each way opens one cover. |
| D   | Scans the binary for previews. | No list of previews to keep. |
| E   | Asks once which build this is. | App Review sees the sandbox too. |
