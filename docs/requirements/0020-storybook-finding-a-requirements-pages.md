# 0020 Finding a requirement's pages in Storybook

## Why

Testers check an app requirement by requirement, so the catalog lists each requirement's pages together, in acceptance order.

## Measurement

requirements whose pages sit in one group

-

requirements with pages in the catalog

## Requirements

- 0020.1
  - Given App maintainer ships a build with pages for one requirement's acceptances declared in two files
    - When I open that requirement's group
      - Then it shows both pages, under the requirement's number and title
- 0020.2
  - Given App maintainer ships a build whose later acceptance's page sits in a file that sorts first
    - When I open the earlier acceptance's page and choose Next
      - Then the later acceptance's page shows
- 0020.3
  - Given App maintainer ships a Debug build with a requirement's pages
    - When I launch it with `--storybook` and that requirement group's title
      - Then the group's pages show side by side
- 0020.4
  - Given App maintainer ships a build without git history
    - When I look over the catalog's groups
      - Then each requirement's group is titled by its number alone
- 0020.5
  - Given App maintainer has a repo of requirement docs
    - When the StorybookHistory tool reads it
      - Then it records each doc's title by its number
