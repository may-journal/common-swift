### 2026.11.13.2000

> On every screen that splits, the Duo's inner one too, the sidebar sits beside the pane and the system resizes it.

- Feat: `ShellSplit` uses the balanced split style, so the sidebar stays beside the pane and its pages at every width.
- Feat: `pageHidesSidebarBelow`, default 0, replaces `sidebarFloatsBelow`, which stays as a deprecated property.
- Feat: `ShellPane(selection:title:systemImage:message:detail:)` shows the system's `ContentUnavailableView` with the app's words.
- Docs: requirement 0013, 0010 reworded, each acceptance proven by one test, and a README table of the configuration.
