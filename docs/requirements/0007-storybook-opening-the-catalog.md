# 0007 Opening the Storybook catalog

## Why

Every way in opens the same catalog, with the app's own pages beside its previews.

## Measurement

ways in that open the catalog

-

ways in a build allows

## Requirements

- 0007.1
  - Given App maintainer runs a Debug build
    - When I tap Storybook in Settings, then Done
      - Then the catalog closes back to Settings
- 0007.2
  - Given App maintainer runs a Debug build on the Mac
    - When I press Option, Command, Shift and D
      - Then the catalog opens
- 0007.3
  - Given App maintainer launches a Debug build with `--storybook` and a page name
    - When the app opens
      - Then that page shows
- 0007.4
  - Given App maintainer adds a page of the app's own
    - When I open the catalog
      - Then the page is listed under its component
- 0007.5
  - Given App maintainer links StorybookKit, which ships a demo preview of its own
    - When I open the catalog
      - Then it lists only the app's pages
