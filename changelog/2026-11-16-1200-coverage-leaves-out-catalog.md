### 2026.11.16.1200

> Changing one Storybook page badges only the pages whose own code changed.

- Fix: the coverage map leaves out catalog files, which import `Storybook`, name a `BookPage` and declare no view.
- Fix: it leaves out a folder of mostly catalog files whole, and keeps screens holding a page or `#Preview`.
- Feat: `--exclude <folder or file>` leaves out a helper the rule misses; `--results` rereads earlier Xcode bundles.
- Docs: requirement 0016, each acceptance proven by one test, the demo's pages and the Storybook README.
