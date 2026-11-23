### 2026.11.23.1500

> A requirement test with arguments maps to the code its cases cover, not to its own test file.

- Fix: `storybook-coverage` matches an Xcode test named with argument labels, such as `test0048_5(story:)`, to its acceptance.
- Fix: a test with a case that fails or throws keeps no profile, so it runs alone and the run reports it.
- Docs: requirements 0018.6 and 0018.7, each proven by one test, and the Storybook README.
