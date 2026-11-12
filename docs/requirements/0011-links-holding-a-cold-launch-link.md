# 0011 Holding a link heard on a cold launch

## Why

A link that launches my app opens what it names, even when it arrives before the screen shows.

## Measurement

links the app reads that open what they name

-

links the app reads

## Requirements

- 0011.1
  - Given App maintainer reads the app's own links
    - When a link arrives before the first screen shows
      - Then the screen opens what the link names
- 0011.2
  - Given App maintainer reads the app's own links
    - When a link of another app arrives
      - Then nothing opens
