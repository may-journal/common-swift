# 0008 Storybook launch settings

## Why

A launch argument draws a preview the same way every time, so a capture can be repeated.

## Measurement

launches whose preview draws as the arguments say

-

launches with Storybook arguments

## Requirements

- 0008.1
  - Given App maintainer launches a page with `--storybook-device duo`
    - When the page opens
      - Then its frame reads 669x951
- 0008.2
  - Given App maintainer launches a page with `--storybook-data-length long`
    - When the page opens
      - Then it shows its long sample
