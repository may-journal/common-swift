# 0002 Opening a link

## Why

A link from a share sheet, widget or handoff opens the screen it names, or says it is gone.

## Measurement

links that open their screen or a Not Found answer

-

links the app receives

## Requirements

- 0002.1
  - Given Developer registers a parser for a host
    - When User opens a link to that host
      - Then the router shows the named screen
- 0002.2
  - Given User opens a link under another scheme
    - When the app handles it
      - Then nothing opens and the answer is not ours
- 0002.3
  - Given User opens a link to deleted content
    - When the app handles it
      - Then the answer is not found and the stack stays put
- 0002.4
  - Given User shares a screen's link
    - When User opens that link
      - Then the same screen opens
- 0002.5
  - Given User opens a link with capitals in its host
    - When the app handles it
      - Then the named screen opens
