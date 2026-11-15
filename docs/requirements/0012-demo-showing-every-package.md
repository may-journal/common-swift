# 0012 Showing every package in the demo

## Why

I open one demo app and see every common-swift package at work before my app adopts it.

## Measurement

packages the demo shows at work

-

packages under Packages/

## Requirements

- 0012.1
  - Given App maintainer runs the demo on an iPad
    - When I pick AdaptiveShell
      - Then its pane shows beside the list of packages
- 0012.2
  - Given App maintainer runs the demo on a phone
    - When I pick AdaptiveShell
      - Then its page covers the list of packages
- 0012.3
  - Given App maintainer runs a Debug build of the demo
    - When I pick Storybook, then open Settings and its Storybook row
      - Then the catalog opens
- 0012.4
  - Given App maintainer runs a Debug build of the demo
    - When I open the catalog
      - Then each package has a page listed
