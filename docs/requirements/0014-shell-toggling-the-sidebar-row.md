# 0014 Closing a page from its sidebar row

## Why

In my app, tapping a sidebar row again closes what it opened, and Back stays the way out of every page.

## Measurement

sidebar rows that close what they opened

-

sidebar rows

## Requirements

- 0014.1
  - Given App maintainer has Settings open in the pane, beside the sidebar
    - When I tap Settings in the sidebar
      - Then Settings closes and the pane shows its prompt
- 0014.2
  - Given App maintainer has Settings open with another page pushed above it
    - When I tap Settings in the sidebar
      - Then both pages close and the pane shows its prompt
- 0014.3
  - Given App maintainer has About open in the pane
    - When I tap Settings in the sidebar, then Back
      - Then Settings replaced About and Back shows the prompt
- 0014.4
  - Given App maintainer has picked an entry
    - When I tap that entry again
      - Then the pick clears and the pane shows its prompt
- 0014.5
  - Given App maintainer has Settings open in the pane
    - When I look at the sidebar
      - Then the Settings row is marked as selected
- 0014.6
  - Given App maintainer has picked an entry
    - When I look at the sidebar
      - Then that entry's row is marked as selected
- 0014.7
  - Given App maintainer runs the shell on a phone, with Settings open
    - When I go Back
      - Then the sidebar shows again
- 0014.8
  - Given App maintainer has Settings open with the sidebar hidden
    - When I go Back
      - Then the pane shows its prompt
