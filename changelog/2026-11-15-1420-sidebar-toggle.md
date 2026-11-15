### 2026.11.15.1420

> Tapping a sidebar row again closes the page or entry it opened, and Back stays on every page.

- Feat: `ShellRow` is a sidebar row that opens its page or pick and closes it on the next tap, at every width.
- Fix: the demo's sidebar closes the package it shows when its row is tapped again in the wide layout.
- Feat: `$path.toggle(page)` opens a page, closes it and any page above it, or replaces a different open page.
- Feat: `picked.toggle(item)` clears the pane's pick, so the pane shows its empty prompt.
- Feat: a row whose page or entry is open shows as selected through the list's own selection.
- Docs: requirement 0014, each acceptance proven by one test, and a README section on the toggle.
