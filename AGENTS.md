# common-swift

A Swift package monorepo: one library product per shared pattern from the may-* apps. See [README.md](README.md) for the layout and how to add a package.

## Rules

Keep plans in GitHub issues and comments. Never commit plan documents, screenshots, or review artifacts.

- Work from a plan. Non-trivial work follows a `Plan`-labeled [GitHub Issue](https://github.com/may-journal/common-swift/issues?q=label%3APlan).
- Extract a pattern only once an app uses it, and record what the apps taught in `docs/architecture/`.
- Keep each package one target with no app types, so any app links it alone.
- Add a changelog entry for each change.
- Run `make requirements` before a push; it runs every requirement test.
