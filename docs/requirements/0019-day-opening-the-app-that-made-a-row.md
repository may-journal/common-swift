# 0019 Opening the app that made a day's row

## Why

Every app shows its part of my day as one row, and one tap opens whichever app made it, at that day.

## Measurement

day rows and chips that open their app at that day

-

day rows and chips

## Requirements

1. A day row opens Captions
   1. GIVEN App maintainer shows a day's Captions row
      1. WHEN I tap the row
         1. THEN Captions opens at that day
2. The chip reads the day
   1. GIVEN App maintainer keys a day as Captions' day line does
      1. WHEN the chip for 2026-12-12 shows
         1. THEN it reads Sat 12 Dec
3. A sibling chip opens May Calendar
   1. GIVEN App maintainer shows the day chip in a sibling app
      1. WHEN I tap the chip
         1. THEN May Calendar opens at that day
4. A foreign day link opens nothing
   1. GIVEN App maintainer reads only Captions' day links
      1. WHEN a List Total day link arrives
         1. THEN nothing opens
5. FamilyDay rows show for each sender
   1. GIVEN App maintainer runs a Debug build of the demo
      1. WHEN I open the catalog page of FamilyDay rows
         1. THEN a row shows for each sender app
