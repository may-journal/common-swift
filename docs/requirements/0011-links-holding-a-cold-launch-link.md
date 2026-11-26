# 0011 Holding a link heard on a cold launch

## Why

A link that launches my app opens what it names, even when it arrives before the screen shows.

## Measurement

links the app reads that open what they name

-

links the app reads

## Requirements

1. A cold launch link opens its screen
   1. GIVEN App maintainer reads the app's own links
      1. WHEN a link arrives before the first screen shows
         1. THEN the screen opens what the link names
2. A foreign link opens nothing
   1. GIVEN App maintainer reads the app's own links
      1. WHEN a link of another app arrives
         1. THEN nothing opens
