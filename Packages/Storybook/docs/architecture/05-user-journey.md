# User Journey

## Legend

```mermaid
flowchart TB
    subgraph kinds["Kinds of step"]
        persona((1 Persona)):::persona
        action(3 Action):::action
        screen[2 Screen]:::screen
        system[(4 System)]:::system
    end

    classDef system fill:#ecfdf5,stroke:#10b981,color:#064e3b,stroke-width:2px
    classDef persona fill:#eef2ff,stroke:#6366f1,color:#312e81,stroke-width:2px
    classDef action fill:#fff7ed,stroke:#f97316,color:#9a3412,stroke-width:2px
    classDef screen fill:#f8fafc,stroke:#64748b,color:#1e293b,stroke-width:2px
```

Numbers match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | A persona node. | Someone this package's system context names. |
| 2   | A screen node. | What the tester or maintainer looks at. |
| 3   | An action node. | A tap, click, shake or line of code. |
| 4   | A system node. | What the package does in reply. |

## Journey

```mermaid
flowchart TB
    maintainer((1 App maintainer)):::persona
    adopt(2 Add the entry, the Settings section and pages<br/>Req 0007):::action
    tester((3 Tester)):::persona
    settings[4 End of Settings<br/>Req 0006]:::screen
    taps(5 Tap Version seven times<br/>Req 0006):::action
    gate[(6 Gate answers and the unlock is saved<br/>Req 0006)]:::system
    open(7 Tap Storybook, shake, or press the shortcut<br/>Req 0007):::action
    catalog[8 Catalog of every page<br/>Req 0007, 0008]:::screen

    maintainer --> adopt
    adopt --> settings
    tester --> settings
    settings --> taps
    taps --> gate
    gate --> open
    open --> catalog

    classDef persona fill:#eef2ff,stroke:#6366f1,color:#312e81,stroke-width:2px
    classDef screen fill:#f8fafc,stroke:#64748b,color:#1e293b,stroke-width:2px
    classDef action fill:#fff7ed,stroke:#f97316,color:#9a3412,stroke-width:2px
    classDef system fill:#ecfdf5,stroke:#10b981,color:#064e3b,stroke-width:2px
```

Numbers match the callout table. The requirement docs live in the repo's root `docs/requirements`, where Fitness reads them.

| #   | Description | Type | Why |
| --- | --- | --- | --- |
| 1   | The app maintainer, wiring the package into an app. | Persona | Same person as the system context. |
| 2   | Adds `storybookEntry(_:)`, `StorybookSettingsSection` and pages of the app's own. | Action | One modifier and one view adopt it. |
| 3   | A person checking a TestFlight or Debug build. | Persona | Same person as the system context. |
| 4   | Version is plain text in an App Store build, a button elsewhere. | Screen | The App Store never shows the catalog. |
| 5   | Seven taps, or clicks on the Mac, turn on the hidden switch. | Action | App Review sees the sandbox too. |
| 6   | The gate's one answer, and the switch kept across launches. | System | A relaunch needs no taps. |
| 7   | Any way in opens the one cover. | Action | Two covers never stack. |
| 8   | The split-view catalog, at the device and data length asked for. | Screen | A capture can be repeated. |
