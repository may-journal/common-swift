# 0003 Holding a request on a cold launch

## Why

A widget tap that launches the app opens its day once the data loads, not before and not twice.

## Measurement

held requests the screen takes exactly once

-

requests heard before the screen is ready

## Requirements

- 0003.1
  - Given User taps a widget while the app is closed
    - When the screen finishes loading
      - Then it takes the request
- 0003.2
  - Given User saw the held tap open its day
    - When the screen asks again
      - Then nothing is waiting
- 0003.3
  - Given User taps two widgets before the screen loads
    - When the screen takes the request
      - Then it gets the newer tap
