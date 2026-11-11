# Containers

The package runs inside the host app's process; its two products are the containers an app links.

```mermaid
C4Container
    title Storybook products

    Person(maintainer, "1 App maintainer")

    System_Boundary(package, "2 Storybook package") {
        Container(core, "3 Storybook", "Swift library", "Gate, unlock, entry, Settings section and catalog")
        Container(sandbox, "4 StorybookSandbox", "Swift library", "The TestFlight gate over StoreKit")
    }

    System_Ext(kit, "5 swift-storybook")
    System_Ext(store, "6 StoreKit")

    Rel(maintainer, core, "A")
    Rel(maintainer, sandbox, "B")
    Rel(sandbox, core, "C")
    Rel(core, kit, "D")
    Rel(sandbox, store, "E")

    UpdateElementStyle(maintainer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(core, $bgColor="#0f766e", $borderColor="#115e59", $fontColor="#ffffff")
    UpdateElementStyle(sandbox, $bgColor="#0f766e", $borderColor="#115e59", $fontColor="#ffffff")
    UpdateElementStyle(kit, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(store, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

```mermaid
C4Container
    title Legend

    Person(p, "Person", "Human actor")
    System_Boundary(b, "Boundary") {
        Container(c, "Container", "Tech", "Runs on its own")
    }
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(c, $bgColor="#0f766e", $borderColor="#115e59", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The app maintainer from the system context. | They pick the products to link. |
| 2   | `Packages/Storybook`, with its own manifest. | It builds and tests alone. |
| 3   | The library every adopting app links. | It never imports StoreKit. |
| 4   | The library that adds `.debugOrSandbox`. | Only an app that wants the TestFlight rule links StoreKit. |
| 5   | eure's preview finder and page types. | The catalog builds on it. |
| 6   | Apple's framework that reads the App Store's signature. | It answers which build this is. |
| A   | Links the library and injects `.debugOnly` or its own gate. | The default never ships the catalog. |
| B   | Links the sandbox library for TestFlight builds. | The choice is explicit. |
| C   | Builds a gate the core library accepts. | One gate type for every rule. |
| D   | Reads every `#Preview` and launch request. | The parsing lives upstream. |
| E   | Asks for the app transaction's environment. | A thrown answer is asked again. |
