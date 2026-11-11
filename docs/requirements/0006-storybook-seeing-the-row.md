# 0006 Seeing the Storybook row

## Why

Testers open the Storybook catalog from the end of Settings, and App Store users never see it.

## Measurement

testers who open the catalog from Settings

-

testers who open Settings

## Requirements

- 0006.1
  - Given App maintainer ships the Settings section in an App Store build
    - When I scroll to the end of Settings
      - Then Version is plain text, with no Storybook row below it
- 0006.2
  - Given App maintainer ships a TestFlight build
    - When I scroll to the end of Settings without tapping Version
      - Then Settings has no Storybook row
- 0006.3
  - Given App maintainer ships a TestFlight build
    - When I tap Version seven times
      - Then the Storybook row appears
- 0006.4
  - Given App maintainer ships a TestFlight build I unlocked before
    - When I open the app again
      - Then the Storybook row is there with no taps
- 0006.5
  - Given App maintainer runs a Debug build
    - When I scroll to the end of Settings
      - Then the Storybook row is there with no taps
- 0006.6
  - Given App maintainer ships a TestFlight build with a Version row of its own
    - When I tap that Version seven times
      - Then the Storybook row appears
