# 0014 Closing a page from its sidebar row

## Why

In my app, tapping a sidebar row again closes what it opened, and Back stays the way out of every page.

## Measurement

sidebar rows that close what they opened

-

sidebar rows

## Requirements

1. Tapping Settings closes it
   1. GIVEN App maintainer has Settings open in the pane
   2. GIVEN beside the sidebar
      1. WHEN I tap Settings in the sidebar
         1. THEN Settings closes
         2. THEN the pane shows its prompt
2. Tapping Settings closes pushed pages too
   1. GIVEN App maintainer has Settings open with another page pushed above it
      1. WHEN I tap Settings in the sidebar
         1. THEN both pages close
         2. THEN the pane shows its prompt
3. Settings replaces About
   1. GIVEN App maintainer has About open in the pane
      1. WHEN I tap Settings in the sidebar and then Back
         1. THEN Settings replaced About
         2. THEN Back shows the prompt
4. Tapping a pick again clears it
   1. GIVEN App maintainer has picked an entry
      1. WHEN I tap that entry again
         1. THEN the pick clears
         2. THEN the pane shows its prompt
5. Settings is marked as selected
   1. GIVEN App maintainer has Settings open in the pane
      1. WHEN I look at the sidebar
         1. THEN the Settings row is marked as selected
6. A picked entry is marked as selected
   1. GIVEN App maintainer has picked an entry
      1. WHEN I look at the sidebar
         1. THEN that entry's row is marked as selected
7. Back shows the sidebar on a phone
   1. GIVEN App maintainer runs the shell on a phone
   2. GIVEN with Settings open
      1. WHEN I go Back
         1. THEN the sidebar shows again
8. Back shows the prompt when the sidebar is hidden
   1. GIVEN App maintainer has Settings open with the sidebar hidden
      1. WHEN I go Back
         1. THEN the pane shows its prompt
