### 2026.11.25.1300

> Storybook reads each acceptance's Then line from a Gherkin requirement doc as it does from bullets.

- Feat: the StorybookHistory tool reads each `SCENARIO: NNNN.N` in a fenced `gherkin` block as an acceptance.
- Feat: a THEN takes the AND and BUT lines under it, joined as one sentence, for the page's panel.
- Docs: acceptance 0020.6 states it, proven by its one test, with its page in the demo's catalog.
- Fix: the demo draws each repeated acceptance (0012.4, 0013.7, 0019.5) as labeled rows on one page, and the grouping test's fixtures take 0020's own pages.
