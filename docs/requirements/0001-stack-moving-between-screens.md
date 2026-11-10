# 0001 Moving between screens

## Why

My app's screens push, pop and come to the front through one path that no redraw can drop.

## Measurement

moves that leave the path the user expects

-

moves through the router

## Requirements

- 0001.1
  - Given Developer binds a stack to a router
    - When the app pushes a screen
      - Then that screen is on top
- 0001.2
  - Given User has Settings open under a detail screen
    - When User taps the Settings gear again
      - Then the stack pops back to Settings, never pushing a second copy
- 0001.3
  - Given User is three screens deep
    - When User taps a date link that goes home
      - Then the stack shows the root
- 0001.4
  - Given User is at the root
    - When the app pops
      - Then nothing changes and the pop reports false
