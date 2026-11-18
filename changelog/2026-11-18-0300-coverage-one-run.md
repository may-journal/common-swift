### 2026.11.18.0300

> The Storybook coverage step runs each suite once and maps again only what changed, so it takes minutes.

- Feat: the `StorybookCoverageScope` product's `.storybookCoverage` trait, or its XCTest observer, records each test's coverage in one run.
- Feat: `storybook-coverage` converts each test's profile with `llvm-profdata` and `llvm-cov`, and runs alone any test without one.
- Feat: a later commit maps again only the acceptances it touches; a build change, unmapped code or `--full` maps them all.
- Feat: Go requirement tests run side by side, and a module with nothing but tests maps them to their files without a run.
- Fix: the tool maps a repo under `/private/var`, where it found no covered file before. Docs: requirement 0018.
