# 0019 Opening the app that made a day's row

## Why

Every app shows its part of my day as one row, and one tap opens whichever app made it, at that day.

## Measurement

day rows and chips that open their app at that day

-

day rows and chips

## Requirements

- 0019.1
  - Given App maintainer shows a day's Captions row
    - When I tap the row
      - Then Captions opens at that day
- 0019.2
  - Given App maintainer keys a day as Captions' day line does
    - When the chip for 2026-12-12 shows
      - Then it reads Sat 12 Dec
- 0019.3
  - Given App maintainer shows the day chip in a sibling app
    - When I tap the chip
      - Then May Calendar opens at that day
- 0019.4
  - Given App maintainer reads only Captions' day links
    - When a List Total day link arrives
      - Then nothing opens
- 0019.5
  - Given App maintainer runs a Debug build of the demo
    - When I open the catalog page of FamilyDay rows
      - Then a row shows for each sender app
