# 0008 Storybook launch settings

## Why

A launch argument draws a preview the same way every time, so a capture can be repeated.

## Measurement

launches whose preview draws as the arguments say

-

launches with Storybook arguments

## Requirements

1. The device argument sets the frame
   1. GIVEN App maintainer launches a page by its acceptance name with `--storybook-device duo`
      1. WHEN the page opens
         1. THEN its frame reads 669x951
2. The data length argument picks the sample
   1. GIVEN App maintainer launches a page by its acceptance name with `--storybook-data-length long`
      1. WHEN the page opens
         1. THEN it shows its long sample
3. The freshness panel is off by default
   1. GIVEN App maintainer launches a page by its acceptance name without `--storybook-freshness`
      1. WHEN the page opens
         1. THEN no freshness panel shows above it
         2. THEN so the preview has the whole canvas
4. The freshness setting is remembered
   1. GIVEN App maintainer launched the catalog once with `--storybook-freshness on`
      1. WHEN a later launch opens a page without it
         1. THEN the page still shows its freshness panel above it
