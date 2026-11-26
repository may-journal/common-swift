# 0015 Seeing what changed in Storybook

## Why

Testers see which catalog pages have code new in this build and how long before the build each changed. So they check the latest work first.

## Measurement

testers who open a page badged New or Changed

-

testers who open the catalog

## Requirements

1. New pages
   1. GIVEN App maintainer ships a build whose commit changed a file a page's acceptance test covers
      1. WHEN I open the catalog
         1. THEN that page's row says New in this build
2. Row dates
   1. GIVEN App maintainer ships a build with a page whose covered code changed 2 days before the build's commit
      1. WHEN I open the catalog
         1. THEN its row says the day it changed and its age
         2. THEN 2 days
         3. THEN counted to the build's commit
3. Build ages
   1. GIVEN App maintainer ships a build made weeks before today
      1. WHEN I open the catalog
         1. THEN each row's age is counted to the build's commit
         2. THEN so it reads the same on any day
4. Freshness panel
   1. GIVEN App maintainer ships a build with a page named by an acceptance
      1. WHEN I open that page with Freshness on
         1. THEN a panel above it shows its acceptance's ID
         2. THEN Then line
         3. THEN the day its code changed
5. No history
   1. GIVEN App maintainer ships a build without git history
      1. WHEN I open the catalog
         1. THEN no row shows a badge
6. Coverage dates
   1. GIVEN App maintainer has a repo whose untracked coverage map lists some acceptances' covered files
   2. GIVEN changed in rebased commits
   3. GIVEN misses others
      1. WHEN the StorybookHistory tool reads it
         1. THEN each acceptance takes the newest change among its files
         2. THEN or else its test's file; one without a test gets none
7. Shallow clone
   1. GIVEN App maintainer builds from a shallow clone
      1. WHEN the StorybookHistory tool reads it
         1. THEN it records no history
         2. THEN so no page shows New
8. Commit count
   1. GIVEN App maintainer ships a build with a page whose code last changed 3 commits before the build's
      1. WHEN I open that page with Freshness on
         1. THEN its panel says 3 commits ago
