# Containers

A container here is a unit that runs on its own. Each package is a library that runs inside the app, so it adds no container; [03-components.md](03-components.md) shows the packages.

```mermaid
C4Container
    title common-swift

    Person(developer, "1 Developer")

    System_Ext(app, "2 App", "Links one or more common-swift products and runs them in process.")

    Rel(developer, app, "A")

    UpdateElementStyle(developer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(app, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
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
| 1   | The developer from the system context. | They add a product to an app. |
| 2   | The app process each linked library runs in. | A library is no runnable unit of its own. |
| A   | The developer builds and runs the app. | The packages are dependencies, not tools. |
