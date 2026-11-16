# 0008 Storybook launch settings

## Why

A launch argument draws a preview the same way every time, so a capture can be repeated.

## Measurement

launches whose preview draws as the arguments say

-

launches with Storybook arguments

## Requirements

- 0008.1
  - Given App maintainer launches a page by its acceptance name with `--storybook-device duo`
    - When the page opens
      - Then its frame reads 669x951
- 0008.2
  - Given App maintainer launches a page by its acceptance name with `--storybook-data-length long`
    - When the page opens
      - Then it shows its long sample
- 0008.3
  - Given App maintainer ships a build with a page whose code is new in it
    - When I open the catalog
      - Then its row shows its ID and label, with no freshness
- 0008.4
  - Given App maintainer launched the catalog once with `--storybook-freshness on`
    - When I open it in a later launch without arguments
      - Then each row still shows the day its page's code changed
