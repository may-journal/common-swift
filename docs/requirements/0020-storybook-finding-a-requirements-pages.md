# 0020 Finding a requirement's pages in Storybook

## Why

Testers check an app requirement by requirement, so the catalog lists each requirement's pages together, in acceptance order.

## Measurement

requirements whose pages sit in one group

-

requirements with pages in the catalog

## Requirements

1. A group joins pages from two files
   1. GIVEN App maintainer ships a build with pages for one requirement's acceptances declared in two files
      1. WHEN I open that requirement's group
         1. THEN it shows both pages
         2. THEN it shows them under the requirement's number
         3. THEN it shows them under the requirement's title
2. Next follows acceptance order
   1. GIVEN App maintainer ships a build whose later acceptance's page sits in a file that sorts first
   2. GIVEN which has the earlier acceptance's page open
      1. WHEN I choose Next
         1. THEN the later acceptance's page shows
3. A launch argument opens a group
   1. GIVEN App maintainer ships a Debug build with a requirement's pages
      1. WHEN I launch it with `--storybook` naming that requirement group's title
         1. THEN the group's pages show side by side
4. A build without history titles groups by number
   1. GIVEN App maintainer ships a build without git history
      1. WHEN I look over the catalog's groups
         1. THEN each requirement's group is titled by its number alone
5. The history tool records doc titles
   1. GIVEN App maintainer has a repo of requirement docs
      1. WHEN the StorybookHistory tool reads it
         1. THEN it records each doc's title by its number
6. The history tool reads Gherkin blocks
   1. GIVEN App maintainer has a requirement doc whose acceptances are SCENARIOs in a fenced Gherkin block
   2. GIVEN with CRLF line endings or not
      1. WHEN the StorybookHistory tool reads it
         1. THEN each acceptance records its THEN line joined with the AND lines under it
