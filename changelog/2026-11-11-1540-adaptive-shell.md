### 2026.11.11.1540

> Every may-* app can lay out its sidebar, pane and pages from one shell, lifted from may-photos.

- Feat: `Packages/AdaptiveShell` stacks pages over the sidebar on a phone, and opens them in a pane beside it on wider screens.
- Feat: a narrow split moves the sidebar aside while a page is open, and the rail keeps the sidebar toggle on iOS.
- Feat: a stack-only shell serves apps with no sidebar yet, and `PendingOpen` holds a cold launch's link until the window's root shows.
- Docs: requirements 0010 and 0011, each proven by one test, and a README on adopting it in may-calendar and secret-gifts.
- Feat: `ShellSplit` is public, so a Mac-only app may draw the split alone.
