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
  - Given App maintainer launches a page by its acceptance name without `--storybook-freshness`
    - When the page opens
      - Then no freshness panel shows above it, so the preview has the whole canvas
- 0008.4
  - Given App maintainer launched the catalog once with `--storybook-freshness on`
    - When a later launch opens a page without it
      - Then the page still shows its freshness panel above it
