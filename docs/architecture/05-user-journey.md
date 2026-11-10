# User Journey

## Legend

```mermaid
flowchart TB
    subgraph types["Node types"]
        persona((1 Persona)):::persona
        screen[2 Screen]:::screen
        action(3 Action):::action
        system[(4 System)]:::system
    end

    classDef persona fill:#eef2ff,stroke:#6366f1,color:#312e81,stroke-width:2px
    classDef screen fill:#f8fafc,stroke:#64748b,color:#1e293b,stroke-width:2px
    classDef action fill:#fff7ed,stroke:#f97316,color:#9a3412,stroke-width:2px
    classDef system fill:#ecfdf5,stroke:#10b981,color:#064e3b,stroke-width:2px
```

Numbers match the callout table.

| #   | Description | Why                                      |
| --- | ----------- | ---------------------------------------- |
| 1   | Persona     | A person the system context declares.    |
| 2   | Screen      | What the person sees.                    |
| 3   | Action      | What the person does.                    |
| 4   | System      | What the product does in reply.          |

## Journey

```mermaid
flowchart TB
    user((1 User)):::persona
    tap(2 Tap a row or the gear<br/>Req 0001):::action
    link(3 Open a link or widget<br/>Req 0002 Req 0003):::action
    leave(4 Leave a screen with a draft<br/>Req 0004):::action
    router[(5 Router moves the path<br/>Req 0001 Req 0002)]:::system
    held[(6 Request waits for the screen<br/>Req 0003)]:::system
    gate[(7 Leave guard asks first<br/>Req 0004)]:::system
    screen[8 The named screen, or Not Found<br/>Req 0001 Req 0002]:::screen
    prompt[9 Save, Discard or Cancel<br/>Req 0004]:::screen
    look(10 Open a screen in light or dark<br/>Req 0005):::action
    theme[(11 Theme hands in the app's tokens<br/>Req 0005)]:::system
    themed[12 Shared views in the app's colors<br/>Req 0005]:::screen

    user --> tap
    user --> link
    user --> leave
    tap --> router
    link --> held
    held --> router
    router --> screen
    leave --> gate
    gate --> prompt
    prompt --> router
    user --> look
    look --> theme
    theme --> themed

    classDef persona fill:#eef2ff,stroke:#6366f1,color:#312e81,stroke-width:2px
    classDef screen fill:#f8fafc,stroke:#64748b,color:#1e293b,stroke-width:2px
    classDef action fill:#fff7ed,stroke:#f97316,color:#9a3412,stroke-width:2px
    classDef system fill:#ecfdf5,stroke:#10b981,color:#064e3b,stroke-width:2px
```

Numbers match the callout table.

| #   | Description | Type | Why |
| --- | --- | --- | --- |
| 1   | The person using a may-* app. | Persona | Same person as the system context. |
| 2   | Pushes a screen, or brings Settings to the front. | Action | A screen never opens twice. |
| 3   | Arrives through `onOpenURL`, maybe on a cold launch. | Action | Links from outside land like taps. |
| 4   | Taps Back, another row, or a link while editing. | Action | Any exit can drop a draft. |
| 5   | Pushes, pops or brings a route to the front. | System | One path, owned by a model. |
| 6   | Holds the request until the data loads. | System | The screen takes it once. |
| 7   | Parks the exit while work is unsaved. | System | One gate for every exit. |
| 8   | Shows the route, or "Not Found" for gone content. | Screen | Never a blank screen. |
| 9   | Asks before leaving unsaved work. | Screen | Save leaves only once it lands. |
| 10  | Opens any screen, in the appearance they chose. | Action | Colors follow light and dark. |
| 11  | Reads the theme the app set at its root, or the standard one. | System | No shared view names app colors. |
| 12  | Draws in the app's colors, spacing and radii. | Screen | Shared views look native to each app. |
