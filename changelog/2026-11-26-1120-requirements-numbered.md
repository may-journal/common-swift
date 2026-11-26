### 2026.11.26.1120

> Every requirement doc reads as numbered acceptances with GIVEN, WHEN and THEN items in caps, so the `requirements` check keeps passing.

- Docs: each acceptance in `docs/requirements` is a named top-level item, and a comma in a step splits into its own GIVEN or THEN.
- Docs: each acceptance keeps its position, so its ID is unchanged and each requirement test keeps its acceptance.
- Docs: acceptances 0013.7 and 0018.4 chain their steps, each proven by its test.
- Test: the 0013.7 and 0018.4 tests name the step they fail at.
