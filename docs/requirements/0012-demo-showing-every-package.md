# 0012 Showing every package in the demo

## Why

I open one demo app and use every common-swift package at work before my app adopts it.

## Measurement

packages the demo opens at work

-

packages under Packages/

## Requirements

- 0012.1
  - Given App maintainer runs the demo on an iPad
    - When I pick AdaptiveShell, then an entry of its diary
      - Then the entry shows in the diary's pane, beside its own sidebar
- 0012.2
  - Given App maintainer runs the demo on a phone
    - When I pick AdaptiveShell, then an entry of its diary
      - Then the entry covers the diary's list
- 0012.3
  - Given App maintainer runs a Debug build of the demo
    - When I pick Storybook
      - Then the catalog opens
- 0012.4
  - Given App maintainer runs a Debug build of the demo
    - When I pick Storybook
      - Then each package has a page listed
