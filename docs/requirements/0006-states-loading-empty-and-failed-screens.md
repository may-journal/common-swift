# 0006 States loading, empty and failed screens

## Why

A screen that loads data always says where it stands and offers a way on, never a blank page.

## Measurement

loading screens that show loading, failure, empty or content

-

loading screens an app shows

## Requirements

- 0006.1
  - Given User opens a screen whose data is still loading
    - When User looks at the screen
      - Then it says Loading and shows no content
- 0006.2
  - Given User opens a screen whose load failed
    - When User looks at the screen
      - Then it shows the failure, its message and Try Again
- 0006.3
  - Given User sees a failed load
    - When User taps Try Again and the load lands
      - Then the content shows
- 0006.4
  - Given User opens a screen that loaded nothing
    - When User looks at the screen
      - Then the empty title and message show
- 0006.5
  - Given User sees an empty screen with an action
    - When User taps the action
      - Then the action runs
- 0006.6
  - Given User opens a screen that loaded items
    - When User looks at the screen
      - Then the items show with no status
- 0006.7
  - Given User changed a row that then shows as a placeholder
    - When the load lands and the placeholder lifts
      - Then the row reads the loading label, then keeps the change
- 0006.8
  - Given User started a slow task
    - When User looks at the status pill
      - Then it names the task and says it is in progress
