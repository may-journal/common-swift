# 0010 Fitting the shell to the screen

## Why

My app shows its sidebar, pane and pages the way each screen has room for, from one shell.

## Measurement

screen sizes where a page opens in the right place

-

screen sizes the app runs on

## Requirements

1. A phone page covers the sidebar
   1. GIVEN App maintainer runs the shell on a phone
      1. WHEN I open a page from the sidebar
         1. THEN the page covers the sidebar
2. An iPad page opens in the pane
   1. GIVEN App maintainer runs the shell on an iPad
      1. WHEN I open a page from the sidebar
         1. THEN the page opens in the pane
         2. THEN beside the sidebar
3. A narrow split keeps the sidebar beside the page
   1. GIVEN App maintainer runs the shell in a narrow split
   2. GIVEN as on the Duo held upright
      1. WHEN I open a page from the sidebar
         1. THEN the page opens beside the sidebar
4. The sidebar comes back after a narrow page
   1. GIVEN App maintainer sets a width below which a page hides the sidebar
   2. GIVEN which has a page open on a narrower screen
      1. WHEN I close it
         1. THEN the sidebar comes back
5. The stack shell covers the first screen
   1. GIVEN App maintainer picks the stack-only shell
      1. WHEN I open a page on an iPad
         1. THEN the page covers the first screen
6. An empty pane shows the prompt
   1. GIVEN App maintainer runs the shell on an iPad with nothing picked
      1. WHEN I look at the pane
         1. THEN the app's prompt shows there
7. A picked entry fills the pane
   1. GIVEN App maintainer runs the shell on an iPad
      1. WHEN I pick an entry in the sidebar
         1. THEN the pane shows that entry
8. The sidebar steps aside on a narrow screen
   1. GIVEN App maintainer sets a width below which a page hides the sidebar
      1. WHEN I open a page on a narrower screen
         1. THEN the sidebar steps aside for the page
