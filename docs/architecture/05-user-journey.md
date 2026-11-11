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

The root journey runs from a commit to an app update. Each package adds its own steps with its first requirement.

```mermaid
flowchart TB
    contributor((1 Contributor)):::persona
    commit(2 Commit a change<br/>Req 0004):::action
    open(3 Open a pull request<br/>Req 0003):::action
    checks[(4 pr-check and Fitness suite<br/>Req 0003, 0004, 0005)]:::system
    merge(5 Merge into main<br/>Req 0001):::action
    releasePR[6 Release pull request<br/>Req 0001, 0003]:::screen
    release(7 Merge the release pull request<br/>Req 0002):::action
    tag[(8 Version, tag and CHANGELOG.md<br/>Req 0002)]:::system
    maintainer((9 App maintainer)):::persona
    update(10 Move the app to the new tag<br/>Req 0002, 0009):::action
    adopt(11 Use a package's features in the app<br/>Req 0006, 0007, 0008):::action

    contributor --> commit
    commit --> open
    open --> checks
    checks --> merge
    merge --> releasePR
    releasePR --> release
    release --> tag
    maintainer --> update
    tag --> update
    update --> adopt

    classDef persona fill:#eef2ff,stroke:#6366f1,color:#312e81,stroke-width:2px
    classDef screen fill:#f8fafc,stroke:#64748b,color:#1e293b,stroke-width:2px
    classDef action fill:#fff7ed,stroke:#f97316,color:#9a3412,stroke-width:2px
    classDef system fill:#ecfdf5,stroke:#10b981,color:#064e3b,stroke-width:2px
```

Numbers match the callout table.

| #   | Description | Type | Why |
| --- | --- | --- | --- |
| 1   | A developer or an agent who changes the repo. | Persona | Same person as the system context. |
| 2   | Commits with a conventional subject and a `changelog/` entry. | Action | The commit hook refuses a red commit. |
| 3   | Opens a pull request with a conventional title that links the entry. | Action | pr-check reads the title and the link. |
| 4   | pr-check, then the Fitness suite with the tests, run on the pull request. | System | A red check blocks the merge. |
| 5   | Merges the green pull request into main. | Action | The push starts only Release Please. |
| 6   | Release Please opens or updates the one release pull request. | Screen | It passes pr-check with no entry file. |
| 7   | Merges the release pull request. | Action | This is the one step that releases. |
| 8   | Release Please writes the version, the `vX.Y.Z` tag and `CHANGELOG.md`. | System | No other workflow writes them. |
| 9   | A developer who keeps a may-* app current. | Persona | Same person as the system context. |
| 10  | Moves the app's dependency on the repo URL to the new tag. | Action | The app takes the release by version, with only the products it picks. |
| 11  | Uses what a package promises; its own journey draws the steps. | Action | Fitness reads every requirement doc here only. |
