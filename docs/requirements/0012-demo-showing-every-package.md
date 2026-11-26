# 0012 Showing every package in the demo

## Why

I open one demo app and see every common-swift package at work before my app adopts it.

## Measurement

packages the demo shows at work

-

packages under Packages/

## Requirements

1. An iPad shows packages beside their list
   1. GIVEN App maintainer runs the demo on an iPad
      1. WHEN I pick AdaptiveShell
         1. THEN its pane shows beside the list of packages
2. A phone page covers the package list
   1. GIVEN App maintainer runs the demo on a phone
      1. WHEN I pick AdaptiveShell
         1. THEN its page covers the list of packages
3. The demo opens the catalog
   1. GIVEN App maintainer runs a Debug build of the demo
      1. WHEN I pick Storybook and then open Settings and its Storybook row
         1. THEN the catalog opens
4. One page lists a row for each package
   1. GIVEN App maintainer runs a Debug build of the demo
      1. WHEN I open the catalog page of packages and search it for Storybook
         1. THEN one page lists a labeled row for each package
         2. THEN Storybook has one page per badge
5. Picking a package again shows the prompt
   1. GIVEN App maintainer runs the demo on an iPad
   2. GIVEN with Storybook picked
      1. WHEN I tap Storybook again
         1. THEN the pane shows its prompt
