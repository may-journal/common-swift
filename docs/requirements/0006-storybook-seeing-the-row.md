# 0006 Seeing the Storybook row

## Why

Testers open the Storybook catalog from the end of Settings, and App Store users never see it.

## Measurement

testers who open the catalog from Settings

-

testers who open Settings

## Requirements

1. App Store builds hide the row
   1. GIVEN App maintainer ships the Settings section in an App Store build
      1. WHEN I scroll to the end of Settings
         1. THEN Version is plain text
         2. THEN with no Storybook row below it
2. TestFlight builds hide the row until unlocked
   1. GIVEN App maintainer ships a TestFlight build
      1. WHEN I scroll to the end of Settings without tapping Version
         1. THEN Settings has no Storybook row
3. Seven taps reveal the row
   1. GIVEN App maintainer ships a TestFlight build
      1. WHEN I tap Version seven times
         1. THEN the Storybook row appears
4. An unlocked row stays
   1. GIVEN App maintainer ships a TestFlight build I unlocked before
      1. WHEN I open the app again
         1. THEN the Storybook row is there with no taps
5. Debug builds show the row
   1. GIVEN App maintainer runs a Debug build
      1. WHEN I scroll to the end of Settings
         1. THEN the Storybook row is there with no taps
6. A Version row of the app's own unlocks it
   1. GIVEN App maintainer ships a TestFlight build with a Version row of its own
      1. WHEN I tap that Version seven times
         1. THEN the Storybook row appears
