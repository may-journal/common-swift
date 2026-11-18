# 0018 Mapping Storybook's coverage in one run

## Why

The coverage step runs before every build an app maintainer looks at, so it must cost minutes, not a quarter of an hour. It runs the suite once rather than once per test, and maps again only what a change can touch. A partial map is never trusted where the tool cannot tell, so badges stay right.

## Measurement

apps whose coverage step runs each suite once

-

apps that show Storybook badges

## Requirements

- 0018.1
  - Given App maintainer puts .storybookCoverage on a package's root suite
    - When the StorybookCoverage tool maps the repo
      - Then it runs that suite once, and each test's row lists only the files that test covers
- 0018.2
  - Given App maintainer has a requirement test outside any suite carrying .storybookCoverage
    - When the StorybookCoverage tool maps the repo
      - Then it runs that test alone after the suite's one run, and its row lists the files it covers
- 0018.3
  - Given App maintainer commits an edit to a file only some acceptances cover, since the map was written on a clean tree
    - When the StorybookCoverage tool maps that commit
      - Then it runs only those acceptances' tests again, and the others keep their rows
- 0018.4
  - Given App maintainer changes the build, adds code no row lists, changes most acceptances, ran last on a dirty tree, or passes --full
    - When the StorybookCoverage tool maps the repo next
      - Then it runs every test again and says why
- 0018.5
  - Given App maintainer keeps Go requirement tests in a module with no Go code besides its tests
    - When the StorybookCoverage tool maps the repo
      - Then it runs none of them, and each maps to its own file
