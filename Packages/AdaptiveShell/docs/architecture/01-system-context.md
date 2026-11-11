# System Context

Who uses the AdaptiveShell package and what it talks to.

```mermaid
C4Context
    title AdaptiveShell package

    Person(maintainer, "1 App maintainer")
    Person(person, "2 App user")
    System(shell, "3 AdaptiveShell", "The app's root: sidebar, pane, pages and held links.")
    System_Ext(app, "4 may-* app")
    System_Ext(system, "5 iOS and macOS")

    Rel(maintainer, app, "A")
    Rel(app, shell, "B")
    Rel(person, app, "C")
    Rel(system, shell, "D")

    UpdateElementStyle(maintainer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(person, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(shell, $bgColor="#1d4ed8", $borderColor="#1e3a8a", $fontColor="#ffffff")
    UpdateElementStyle(app, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
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
| 1   | The developer who adds the shell to a may-* app. | They hand it the path and the views. |
| 2   | A person using the app on a phone, an iPad or the Mac. | The layout follows their screen. |
| 3   | The shell, lifted from may-photos. | The root is written once for every app. |
| 4   | An app that draws its root with the shell. | It owns its pages and words. |
| 5   | Gives the size class, the window's width and opened links. | The shell lays out from them. |
| A   | Builds the root with the shell and a pending open. | One view and one modifier adopt it. |
| B   | Hands over its path, sidebar, pane, pages and link reader. | The routes stay the app's own. |
| C   | Opens pages and taps links. | Pages land where the screen has room. |
| D   | Reports the screen's width and the links it opens. | A narrow split moves the sidebar aside. |
