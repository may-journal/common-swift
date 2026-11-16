### 2026.11.16.0200

> Testers see which Storybook pages have code new in this build and how long before the build each one changed.

- Feat: a page named by an acceptance, such as `0006.3 unlocked`, shows its ID and label, listed under its Swift file.
- Feat: the `StorybookHistory` plugin dates each acceptance by the newest mainline change to its test's covered files, counted to the build's commit.
- Feat: a page's ID chip fades with age beside a meter; its header shows its Then line, commits ago and a five-week scale.
- Fix: the demo shows a page per acceptance, or a card without a screen; it applies the plugin and builds without an icon.
- Docs: requirement 0015, each proven by one test, the coverage map and its script, the README's badges section and the architecture views.
