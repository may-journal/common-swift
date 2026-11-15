### 2026.11.15.0421

> The synced Dependabot caller passes the writer test, since it writes only to Dependabot's own branch.

- Fix: requirement 0002.3 allows the shared `dependabot-pr.yml` job beside auto-merge and the release job.
- Test: the writer test checks that every job that can write is allowed, and that the release job is one.
- Docs: 0002.3 says a workflow may complete Dependabot's pull request.
