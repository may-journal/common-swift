# 0017 Keeping Storybook's coverage map current

## Why

Every build an app maintainer looks at runs one coverage step from common-swift first, and it costs time only when the code changed. So no app copies a wrapper script or a commit stamp, and badges never date from a stale map.

## Measurement

apps whose builds run the StorybookCoverage tool with no wrapper script of their own

-

apps that show Storybook badges

## Requirements

1. A current map is skipped
   1. GIVEN App maintainer has a repo whose coverage map the StorybookCoverage tool wrote for HEAD on a clean tree
      1. WHEN the tool runs again with the same arguments
         1. THEN it skips
         2. THEN leaving the map as it was
2. A stale map is written again
   1. GIVEN App maintainer has a repo with an edit or an untracked test file since the map was written
      1. WHEN the StorybookCoverage tool runs
         1. THEN it writes the map again
         2. THEN again on each run until the tree is clean
3. Xcodebuild arguments pass through
   1. GIVEN App maintainer passes xcodebuild arguments after --
   2. GIVEN such as -allowProvisioningUpdates
      1. WHEN the StorybookCoverage tool maps an Xcode scheme
         1. THEN its build passes them on
         2. THEN its test listing passes them on
         3. THEN its one run of the suite passes them on
         4. THEN each test's own run passes them on
