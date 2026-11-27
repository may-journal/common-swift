# 0013 Sharing the screen with the sidebar

## Why

My app's sidebar sits beside the pane on every screen that splits, and the empty pane shows my words.

## Measurement

screen sizes where the sidebar sits beside the pane

-

screen sizes where the shell splits

## Requirements

1. Sidebar beside pane
   1. GIVEN App maintainer runs the shell on the Duo's inner screen
      1. WHEN I look at the sidebar
         1. THEN it sits beside the pane
2. Empty pane words
   1. GIVEN App maintainer gives the empty pane only its title
   2. GIVEN which gives it a symbol
   3. GIVEN which gives it a message
      1. WHEN I look at the pane with nothing picked
         1. THEN the pane shows those words
3. Narrowing drag
   1. GIVEN App maintainer runs the shell on the Duo's inner screen
      1. WHEN I drag the sidebar's edge narrower
         1. THEN the sidebar narrows
4. Half screen stop
   1. GIVEN App maintainer keeps the shell's default widths on the Duo's inner screen
      1. WHEN I drag the sidebar's edge as far right as it goes
         1. THEN the sidebar stops at half the screen
5. Six tenths stop
   1. GIVEN App maintainer lets the sidebar take six tenths of the split
      1. WHEN I drag the sidebar's edge as far right as it goes
         1. THEN the sidebar stops at six tenths of the screen
6. Default border
   1. GIVEN App maintainer keeps the shell's default border
      1. WHEN I look where the sidebar meets the pane on a screen of three pixels a point
         1. THEN a line one pixel wide shows there
7. Border settings
   1. GIVEN App maintainer keeps the shell's sidebar border
      1. WHEN I turn the border off
         1. THEN no line shows where the sidebar meets the pane
      2. WHEN I give the border two points
         1. THEN the line between them is two points wide
8. Whole screen
   1. GIVEN App maintainer runs the shell on the Duo's inner screen
   2. GIVEN side rail included
   3. GIVEN with a wider window open too
      1. WHEN the shell works out how far the sidebar may go
         1. THEN it allows the middle of its own whole screen
