### 2026.11.13.2000

> On every screen that splits, the Duo's inner one too, the sidebar sits beside the pane and the system resizes it.

- Fix: the system gets the sidebar's widths, so it drags up to half its own whole window, side rail included.
- Feat: `sidebarMaxFraction`, default 0.5, and an optional cap in `sidebarWidth.max`, each overridable by the app.
- Feat: `sidebarBorder`, a one-pixel separator line between sidebar and pane on iOS, which an app restyles or hides.
- Feat: `pageHidesSidebarBelow` replaces `sidebarFloatsBelow`, and `ShellPane` shows `ContentUnavailableView` with the app's words.
- Docs: requirements 0010 and 0013, each acceptance proven by one test, and a README table of every default.
