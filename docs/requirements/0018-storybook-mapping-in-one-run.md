# 0018 Mapping Storybook's coverage in one run

## Why

The coverage step runs before every build an app maintainer looks at, so it must cost minutes, not a quarter of an hour. It runs the suite once rather than once per test, and maps again only what a change can touch. A partial map is never trusted where the tool cannot tell, so badges stay right.

## Measurement

apps whose coverage step runs each suite once

-

apps that show Storybook badges

## Requirements

1. Suites
   1. GIVEN App maintainer puts .storybookCoverage on a package's root suite
   2. GIVEN again on a suite inside it
      1. WHEN the StorybookCoverage tool maps the repo
         1. THEN it runs that suite once
         2. THEN each test's row lists only the files that test covers
2. Lone test
   1. GIVEN App maintainer has a requirement test outside any suite carrying .storybookCoverage
      1. WHEN the StorybookCoverage tool maps the repo
         1. THEN it runs that test alone after the suite's one run
         2. THEN its row lists the files it covers
3. Edits
   1. GIVEN App maintainer commits an edit to a file only some acceptances cover
   2. GIVEN since the map was written on a clean tree
      1. WHEN the StorybookCoverage tool maps that commit
         1. THEN it runs only those acceptances' tests again
         2. THEN the others keep their rows
4. Full rerun
   1. GIVEN App maintainer has a clean map
      1. WHEN the build changes
         1. THEN all rerun saying why
      2. WHEN files go unmapped
         1. THEN all rerun
      3. WHEN most rows change
         1. THEN all rerun
      4. WHEN a dirty run happened
         1. THEN all rerun
      5. WHEN I pass --full
         1. THEN all rerun
5. Go
   1. GIVEN App maintainer keeps Go requirement tests in a module with no Go code besides its tests
      1. WHEN the StorybookCoverage tool maps the repo
         1. THEN it runs none of them
         2. THEN each maps to its own file
6. Argument tests
   1. GIVEN App maintainer has a requirement test with arguments
   2. GIVEN such as test0001_3(count:)
   3. GIVEN in an Xcode scheme
      1. WHEN the StorybookCoverage tool maps the repo
         1. THEN it runs that test in the suite's one run
         2. THEN its row lists the files its cases cover
7. Failures
   1. GIVEN App maintainer has a requirement test with arguments
   2. GIVEN one of its cases fails or throws
      1. WHEN the StorybookCoverage tool maps the repo
         1. THEN it runs that test alone
         2. THEN says a requirement test failed and writes no map
