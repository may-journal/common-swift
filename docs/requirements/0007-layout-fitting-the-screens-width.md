# 0007 Layout fitting the screen's width

## Why

Every screen lays out for the width it has, phone or pad or Mac, in the app's own sizes.

## Measurement

screens that lay out for their width

-

screens an app shows on a phone, a pad and a Mac

## Requirements

- 0007.1
  - Given User is on a wide screen
    - When User opens a note from the list
      - Then the list and the note show side by side
- 0007.2
  - Given User is on a narrow screen
    - When User opens the notes screen
      - Then only the list shows
- 0007.3
  - Given User sees the list on a narrow screen
    - When User taps a note
      - Then the note pushes over the list
- 0007.4
  - Given User is on a wide screen
    - When User reads a column of text
      - Then the column stops at the readable width
- 0007.5
  - Given User is on a narrow screen
    - When User reads a column of text
      - Then the column fills the width less the margins
- 0007.6
  - Given User is on a narrow screen
    - When User opens a grid of tiles
      - Then the tiles fill each row, none under the minimum
- 0007.7
  - Given User is on a wide screen
    - When User opens a grid of tiles
      - Then more tiles share each row
- 0007.8
  - Given User sees a card in an app with its own theme
    - When User looks at the card's content
      - Then it sits inside the theme's inset
