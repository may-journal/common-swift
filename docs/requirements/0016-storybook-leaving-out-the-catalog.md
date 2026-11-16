# 0016 Leaving the catalog out of Storybook's badges

## Why

Changing one catalog page badges only the pages whose own code changed, not every page whose test opens the catalog. So New still points testers at the latest work.

## Measurement

acceptances whose coverage lists no catalog file

-

acceptances in the coverage map

## Requirements

- 0016.1
  - Given App maintainer keeps catalog pages and a helper in one folder, beside screens importing Storybook or holding a #Preview
    - When the StorybookCoverage tool maps the repo
      - Then it leaves out that folder and keeps both screens and the package's own code
- 0016.2
  - Given App maintainer keeps a catalog helper where the rule misses it
    - When the StorybookCoverage tool maps the repo with --exclude naming its folder
      - Then it leaves out that folder's files, and none whose name only starts the same way
