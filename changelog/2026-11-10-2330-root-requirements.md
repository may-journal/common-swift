### 2026.11.10.2330

> The root build and release flow states its requirements, and one test proves each.

- Feat: a merge to main starts only Release Please, which keeps one release pull request from the shared workflow and config.
- Docs: five requirement docs state the release pull request, the version and tag, pr-check, red checks and one test per acceptance.
- Test: one Go test per acceptance copies the repo from the git index, runs git and fitness, and replays gh by path.
- Docs: the journey runs from a commit to an app update for the Contributor and the App maintainer, citing each requirement.
- Docs: the containers view records one root release component and one `vX.Y.Z` tag for every package.
