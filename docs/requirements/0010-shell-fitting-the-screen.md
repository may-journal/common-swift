# 0010 Fitting the shell to the screen

## Why

My app shows its sidebar, pane and pages the way each screen has room for, from one shell.

## Measurement

screen sizes where a page opens in the right place

-

screen sizes the app runs on

## Requirements

- 0010.1
  - Given App maintainer runs the shell on a phone
    - When I open a page from the sidebar
      - Then the page covers the sidebar
- 0010.2
  - Given App maintainer runs the shell on an iPad
    - When I open a page from the sidebar
      - Then the page opens in the pane, beside the sidebar
- 0010.3
  - Given App maintainer runs the shell in a narrow split, as on the Duo held upright
    - When I open a page from the sidebar
      - Then the sidebar steps aside for the page
- 0010.4
  - Given App maintainer runs the shell in a narrow split
    - When I open a page, then close it
      - Then the sidebar comes back
- 0010.5
  - Given App maintainer picks the stack-only shell
    - When I open a page on an iPad
      - Then the page covers the first screen
- 0010.6
  - Given App maintainer runs the shell on an iPad with nothing picked
    - When I look at the pane
      - Then the app's prompt shows there
- 0010.7
  - Given App maintainer runs the shell on an iPad
    - When I pick an entry in the sidebar
      - Then the pane shows that entry
