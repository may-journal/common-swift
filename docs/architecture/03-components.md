# Components

This splits the pipelines in [02-containers.md](02-containers.md) into the build and test steps. They run for every package alike.

```mermaid
C4Component
    title common-swift build and test

    Person(contributor, "1 Contributor")

    Container_Boundary(ci, "2 Package build and test") {
        Component(find, "3 Find changed packages", "Shell", "Lists each package a pull request touches")
        Component(build, "4 Build package", "Swift", "Compiles one package on its own")
        Component(test, "5 Test package", "Swift", "Runs the package's requirement tests")
        Component(report, "6 Report result", "GitHub Actions", "Posts the result as a check")
    }

    System_Ext(github, "7 GitHub")

    Rel(contributor, github, "A")
    Rel(github, find, "B")
    Rel(find, build, "C")
    Rel(build, test, "D")
    Rel(test, report, "E")
    Rel(report, github, "F")

    UpdateElementStyle(contributor, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(find, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(build, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(test, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(report, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(github, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

```mermaid
C4Component
    title Legend

    Person(p, "Person", "Human actor")
    Container_Boundary(cb, "Container boundary") {
        Component(c, "Component", "Tech", "Logical unit")
    }
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(c, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The person whose push starts the steps. | The steps need no manual start. |
| 2   | The container that proves each package. | One flow for every package. |
| 3   | Lists the packages a pull request touches. | Only changed packages rebuild. |
| 4   | Compiles a package from its own manifest. | A package builds alone. |
| 5   | Runs the package's tests. | A package proves its own requirements. |
| 6   | Posts the result as a check. | The result gates the merge. |
| 7   | Hosts the pull request and the checks. | It is the one door for every change. |
| A   | Pushes the change to a pull request. | The push starts the flow. |
| B   | Starts the workflow. | No manual build step. |
| C   | Hands over the package list. | Each package is built in turn. |
| D   | Hands over the built package. | Tests run on what was built. |
| E   | Hands over the test result. | The check reflects the tests. |
| F   | Posts the check. | Reviewers see one result. |
