# Containers

A container here is a unit that runs on its own. The repo ships only libraries, so it adds none; GitHub's pipelines build, check and deliver them.

```mermaid
C4Container
    title common-swift build and deploy

    Person(contributor, "1 Contributor")

    System_Ext(github, "2 GitHub", "Hosts the repo and runs its fitness, build and test pipelines.")
    System_Ext(apps, "3 may-* apps", "Depend on the delivered packages.")

    Rel(contributor, github, "A")
    Rel(github, apps, "B")

    UpdateElementStyle(contributor, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(github, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(apps, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

```mermaid
C4Container
    title Legend

    Person(p, "Person", "Human actor")
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The contributor from the system context. | They push a change to a branch. |
| 2   | Runs the fitness checks, the package build and tests, and the release. | The repo keeps no server of its own. |
| 3   | The apps that receive the delivered packages. | They update a package by its version. |
| A   | Pushes the branch and opens a pull request. | Review comes before main. |
| B   | Delivers each package as a Swift package. | The app takes it through its manifest. |
