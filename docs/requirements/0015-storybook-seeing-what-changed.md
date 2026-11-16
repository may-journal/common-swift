# 0015 Seeing what changed in Storybook

## Why

Testers see which catalog pages are new in this build and how long ago each changed. So they check the latest work first.

## Measurement

testers who open a page badged New or Changed

-

testers who open the catalog

## Requirements

- 0015.1
  - Given App maintainer ships a build whose commit added a page's acceptance
    - When I open the catalog
      - Then that page's row says New in this build
- 0015.2
  - Given App maintainer ships a build with a page whose acceptance changed after it was added
    - When I open the catalog
      - Then its row says how long ago it changed
- 0015.3
  - Given App maintainer ships a build with a page whose acceptance never changed
    - When I open the catalog
      - Then its row says the day it was added
- 0015.4
  - Given App maintainer ships a build with a page named by an acceptance
    - When I open that page
      - Then its acceptance's ID, Then line, and dates show above it
- 0015.5
  - Given App maintainer ships a build without git history
    - When I open the catalog
      - Then no row shows a badge
- 0015.6
  - Given App maintainer has a repo whose requirement docs were committed, renamed, and changed in a rebased commit
    - When the StorybookHistory tool reads it
      - Then each acceptance has the commit that added it, when its last change was written, and its Then line
- 0015.7
  - Given App maintainer builds from a shallow clone
    - When the StorybookHistory tool reads it
      - Then it records no history, so no page shows New
- 0015.8
  - Given App maintainer ships a build with a page whose acceptance never changed
    - When I open that page
      - Then only the day it was added shows above it
