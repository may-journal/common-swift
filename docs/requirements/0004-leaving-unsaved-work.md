# 0004 Leaving unsaved work

## Why

No tap, swipe or link throws away a draft without asking Save, Discard or Cancel.

## Measurement

leaves with unsaved work that ask first

-

leaves requested from an editing screen

## Requirements

- 0004.1
  - Given User has nothing unsaved
    - When User leaves the screen
      - Then the screen closes at once
- 0004.2
  - Given User has an unsaved draft
    - When User leaves the screen
      - Then the prompt asks first and the screen stays
- 0004.3
  - Given User sees the Save, Discard or Cancel prompt
    - When User taps Cancel
      - Then the screen stays with the draft
- 0004.4
  - Given User sees the Save, Discard or Cancel prompt
    - When User taps Discard
      - Then the screen closes without saving
- 0004.5
  - Given User sees the Save, Discard or Cancel prompt
    - When User taps Save and the save lands
      - Then the screen closes
- 0004.6
  - Given User sees the Save, Discard or Cancel prompt
    - When User taps Save and the save fails
      - Then the screen says so and stays with the draft
- 0004.7
  - Given User has an unsaved draft
    - When User opens a link to another screen
      - Then the prompt asks first
- 0004.8
  - Given User taps Save and the entry is deleted mid-save
    - When the save lands
      - Then the screen does not leave for the gone entry
