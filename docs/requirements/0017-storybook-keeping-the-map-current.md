# 0017 Keeping Storybook's coverage map current

## Why

Every build an app maintainer looks at runs one coverage step from common-swift first, and it costs time only when the code changed. So no app copies a wrapper script or a commit stamp, and badges never date from a stale map.

## Measurement

apps whose builds run the StorybookCoverage tool with no wrapper script of their own

-

apps that show Storybook badges

## Requirements

- 0017.1
  - Given App maintainer has a repo whose coverage map the StorybookCoverage tool wrote for HEAD on a clean tree
    - When the tool runs again with the same arguments
      - Then it skips, leaving the map as it was
- 0017.2
  - Given App maintainer has a repo with an edit or an untracked test file since the map was written
    - When the StorybookCoverage tool runs
      - Then it writes the map again, and again on each run until the tree is clean
- 0017.3
  - Given App maintainer passes xcodebuild arguments after --, such as -allowProvisioningUpdates
    - When the StorybookCoverage tool maps an Xcode scheme
      - Then each xcodebuild call it makes passes them on
