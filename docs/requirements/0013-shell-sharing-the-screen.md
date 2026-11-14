# 0013 Sharing the screen with the sidebar

## Why

My app's sidebar sits beside the pane on every screen that splits, and the empty pane shows my words.

## Measurement

screen sizes where the sidebar sits beside the pane

-

screen sizes where the shell splits

## Requirements

- 0013.1
  - Given App maintainer runs the shell on the Duo's inner screen
    - When I look at the sidebar
      - Then it sits beside the pane
- 0013.2
  - Given App maintainer gives the empty pane only its title, symbol and message
    - When I look at the pane with nothing picked
      - Then the pane shows those words
- 0013.3
  - Given App maintainer runs the shell on the Duo's inner screen
    - When I drag the sidebar's edge narrower
      - Then the sidebar narrows
- 0013.4
  - Given App maintainer keeps the shell's default widths on the Duo's inner screen
    - When I drag the sidebar's edge as far right as it goes
      - Then the sidebar stops at half the screen
- 0013.5
  - Given App maintainer lets the sidebar take six tenths of the split
    - When I drag the sidebar's edge as far right as it goes
      - Then the sidebar stops at six tenths of the screen
- 0013.6
  - Given App maintainer keeps the shell's default border
    - When I look between the sidebar and the pane on a screen of three pixels a point
      - Then a line one pixel wide shows there
- 0013.7
  - Given App maintainer turns the border off, or gives it two points
    - When I look between the sidebar and the pane
      - Then no line shows, or the line is two points wide
