# System Context

How common-swift is built, checked and delivered.

```mermaid
C4Context
    title common-swift build and deploy

    Person(contributor, "1 Contributor")
    System(common, "2 common-swift", "A monorepo of Swift packages, built, checked and delivered through pull requests.")
    System_Ext(github, "3 GitHub")
    System_Ext(apps, "4 may-* apps")

    Rel(contributor, github, "A")
    Rel(github, common, "B")
    Rel(common, apps, "C")

    UpdateElementStyle(contributor, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(common, $bgColor="#1d4ed8", $borderColor="#1e3a8a", $fontColor="#ffffff")
    UpdateElementStyle(github, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(apps, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
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
| 1   | A developer or an agent who changes the repo. | Every change arrives as a pull request. |
| 2   | This repository: separate Swift packages with one build and delivery flow. | The flow is written once for every package. |
| 3   | Hosts the repo, runs the pull request flow and the checks. | Nothing merges without its checks. |
| 4   | The may-* apps that depend on the packages. | The apps receive packages, never source copies. |
| A   | Opens a pull request. | Work is reviewed before it reaches main. |
| B   | Starts the build, the tests and the fitness checks. | Each change is proved in CI. |
| C   | Delivers the packages as Swift packages. | An app takes a package through its manifest. |
