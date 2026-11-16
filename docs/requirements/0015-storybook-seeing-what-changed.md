# 0015 Seeing what changed in Storybook

## Why

Testers see which catalog pages have code new in this build and how long before the build each changed. So they check the latest work first.

## Measurement

testers who open a page badged New or Changed

-

testers who open the catalog

## Requirements

- 0015.1
  - Given App maintainer ships a build whose commit changed a file a page's acceptance test covers
    - When I open the catalog with Freshness on
      - Then that page's row says New in this build
- 0015.2
  - Given App maintainer ships a build with a page whose covered code changed 2 days before the build's commit
    - When I open the catalog with Freshness on
      - Then its row says the day it changed and its age, 2 days, counted to the build's commit
- 0015.3
  - Given App maintainer ships a build made weeks before today
    - When I open the catalog with Freshness on
      - Then each row's age is counted to the build's commit, so it reads the same on any day
- 0015.4
  - Given App maintainer ships a build with a page named by an acceptance
    - When I open that page with Freshness on
      - Then its acceptance's ID, Then line, and the day its code changed show above it
- 0015.5
  - Given App maintainer ships a build without git history
    - When I open the catalog with Freshness on
      - Then no row shows a badge
- 0015.6
  - Given App maintainer has a repo whose coverage map lists the source files each acceptance's test covers, changed in rebased commits
    - When the StorybookHistory tool reads it
      - Then each acceptance takes the newest change among its files: its author date, commit, commits before the build, and its Then line
- 0015.7
  - Given App maintainer builds from a shallow clone
    - When the StorybookHistory tool reads it
      - Then it records no history, so no page shows New
- 0015.8
  - Given App maintainer ships a build with a page whose code last changed 3 commits before the build's
    - When I open that page with Freshness on
      - Then its header says 3 commits ago
