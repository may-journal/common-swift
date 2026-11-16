### 2026.11.16.0200

> Testers see which Storybook pages have code new in this build and how long before the build each one changed.

- Feat: a page named by an acceptance, such as `0006.3 unlocked`, shows its ID and label, listed under its Swift file.
- Feat: the `StorybookHistory` plugin dates each acceptance by the newest mainline change to its test's covered files, counted to the build's commit.
- Feat: each ID chip fades with age beside a meter; a header flame button shows a page's commits ago and age scale.
- Fix: the demo shows a page per acceptance, or a card without a screen; it applies the plugin and builds without an icon.
- Docs: requirement 0015 and 0008.3–0008.4, each proven by one test, the coverage map, its script, the README and architecture views.
