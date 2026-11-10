# 0005 Theme drawing in the app's tokens

## Why

A shared view draws in the colors, spacing and radii the app hands in, in both appearances.

## Measurement

shared views that draw with the app's theme

-

shared views an app draws

## Requirements

- 0005.1
  - Given User is in an app with its own theme
    - When User opens a screen with a shared view
      - Then the view draws in the app's accent, spacing and radii
- 0005.2
  - Given User is in an app with no theme
    - When User opens a screen with a shared view
      - Then the view draws in the standard spacing and radii
- 0005.3
  - Given User sees a color with a light and a dark value
    - When User has chosen dark appearance
      - Then the dark value draws
- 0005.4
  - Given User sees a color with a light and a dark value
    - When User has chosen light appearance
      - Then the light value draws
- 0005.5
  - Given User has a color the app stored as `#RRGGBB`
    - When User opens the screen showing it
      - Then the stored color draws
- 0005.6
  - Given User has a color the app stored malformed
    - When User opens the screen showing it
      - Then the app's fallback color draws
- 0005.7
  - Given User is on a screen where one part sets its own theme
    - When User opens the screen
      - Then that part uses its theme and the rest keeps the app's
