# 0007 Opening the Storybook catalog

## Why

Every way in opens the same catalog, with the app's own pages beside its previews.

## Measurement

ways in that open the catalog

-

ways in a build allows

## Requirements

1. Done closes the catalog
   1. GIVEN App maintainer runs a Debug build
   2. GIVEN which opened the catalog from Storybook in Settings
      1. WHEN I tap Done
         1. THEN the catalog closes back to Settings
2. A Mac shortcut opens the catalog
   1. GIVEN App maintainer runs a Debug build on the Mac
      1. WHEN I press Option-Command-Shift-D
         1. THEN the catalog opens
3. A launch argument opens a page
   1. GIVEN App maintainer launches a Debug build with `--storybook` naming a page
      1. WHEN the app opens
         1. THEN that page shows
4. The app's own pages list under their requirement
   1. GIVEN App maintainer adds a page of the app's own
      1. WHEN I open the catalog
         1. THEN the page is listed under its requirement's number
5. The demo preview stays out
   1. GIVEN App maintainer links StorybookKit
   2. GIVEN which ships a demo preview of its own
      1. WHEN I open the catalog
         1. THEN it lists only the app's pages
