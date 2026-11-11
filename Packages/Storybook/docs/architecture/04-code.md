# Code

The types an app meets, from [03-components.md](03-components.md).

```mermaid
classDiagram
    class StorybookAvailability["1 StorybookAvailability"] {
        +isBuildAllowed
        +isUnlocked
        +resolve()
        +tapsVersion()
        +presentsCatalog()
    }
    class StorybookGate["2 StorybookGate"] {
        +isDebug
        +debugOnly
        +debugOrSandbox
    }
    class StorybookConfiguration["3 StorybookConfiguration"] {
        +labels
        +identifiers
        +version
        +pages
        +arguments
    }
    class StorybookSettingsSection["4 StorybookSettingsSection"]
    class StorybookEntry["5 StorybookEntry"]
    class StorybookSetting["6 StorybookSetting"] {
        <<protocol>>
        +storageKey
        +argument
        +next
    }

    StorybookAvailability --> StorybookGate : A
    StorybookAvailability --> StorybookConfiguration : B
    StorybookSettingsSection --> StorybookAvailability : C
    StorybookEntry --> StorybookAvailability : D
    StorybookEntry --> StorybookSetting : E

    style StorybookAvailability fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style StorybookGate fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style StorybookConfiguration fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style StorybookSettingsSection fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style StorybookEntry fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style StorybookSetting fill:#6d28d9,stroke:#4c1d95,color:#ffffff
```

```mermaid
classDiagram
    class Example {
        +property
        +method()
    }
    class Parent
    class Child
    Parent <|-- Child : inherits
    Parent --> Child : uses

    style Example fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Parent fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Child fill:#6d28d9,stroke:#4c1d95,color:#ffffff
```

Numbers on classes and letters on relationships match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The state machine: build answer, seven-tap counter, unlock saved in user defaults. | One object per app. |
| 2   | Who may see the catalog, injected by the app. | `.debugOnly` is the safe default. |
| 3   | The host's words, accessibility IDs, version, pages and launch arguments. | The package hardcodes no app. |
| 4   | The version row and the Storybook row. | An app drops in one view. |
| 5   | The modifier holding the one cover, the shake and ⌥⌘⇧D. | Every way in meets here. |
| 6   | A header choice saved per launch, such as the device frame. | Arguments and buttons set one value. |
| A   | Asks the gate once, again after a failed answer. | Offline launches recover. |
| B   | Reads the host's configuration. | Labels come from the host. |
| C   | Shows the rows the availability allows. | The row and the cover agree. |
| D   | Opens the cover when the availability says so. | No second cover. |
| E   | Applies each `--storybook-*` argument once. | Header taps hold after redraws. |

## Tests

`swift test` in this folder runs one test per acceptance of requirements 0006, 0007 and 0008. Each renders a small diary app with the package, as an app does, and the App Store's answer is replayed.
