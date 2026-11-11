### 2026.11.11.0420

> An app that keeps its own Version row adopts Storybook, and the catalog lists only the app's pages.

- Feat: `StorybookRowSection` is the Storybook row alone, for an app whose Version row does more, such as a hold that opens its flags.
- Fix: the catalog leaves out the demo preview StorybookKit ships, which an app's catalog found in its binary.
- Docs: requirements 0006.6 and 0007.5 state both, each proven by one test that fails when its Given flips.
