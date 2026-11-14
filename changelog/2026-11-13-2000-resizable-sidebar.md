### 2026.11.13.2000

> On every screen that splits, the Duo's inner one too, the sidebar sits beside the pane and the system resizes it.

- Fix: `ShellSplit` keeps the system's automatic split style, as may-photos does, so a person can drag the sidebar wider or narrower.
- Feat: `pageHidesSidebarBelow`, default 0, replaces `sidebarFloatsBelow`, which stays as a deprecated property.
- Feat: `ShellPane(selection:title:systemImage:message:detail:)` shows the system's `ContentUnavailableView` with the app's words.
- Docs: requirement 0013, 0010 reworded, each acceptance proven by one test, and a README table of the configuration.
