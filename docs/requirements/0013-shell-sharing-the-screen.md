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
    - When I drag the sidebar's edge wider
      - Then the sidebar widens
