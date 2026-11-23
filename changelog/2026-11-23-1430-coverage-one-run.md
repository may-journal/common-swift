### 2026.11.23.1430

> The Storybook coverage step runs each suite once and maps again only what a commit changed.

- Feat: the `StorybookCoverageScope` trait, or its XCTest observer, records each test's coverage in one run; a test without a profile runs alone.
- Feat: a later commit maps again only the acceptances it touches, and a test-only Go module maps without a run.
- Fix: the tool maps a repo under `/private/var`.
- Docs: requirement 0018, each acceptance proven by one test, and the Storybook README's coverage recipe.
