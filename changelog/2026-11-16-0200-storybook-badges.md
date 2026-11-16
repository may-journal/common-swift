### 2026.11.16.0200

> Testers see which Storybook pages are new in this build and how long ago each one changed.

- Feat: a page named by an acceptance, such as `0006.3 unlocked`, shows its ID and label, listed under its Swift file.
- Feat: the `StorybookHistory` plugin bundles each acceptance's added and changed dates from git, and none from a shallow clone.
- Feat: rows and cards show New, when the acceptance changed, or when it was added; a page shows its Then line.
- Fix: the demo app and the test app name their pages by acceptance, and the demo applies the plugin.
- Docs: requirement 0015, each acceptance proven by one test, the README's badges section and the architecture views.
