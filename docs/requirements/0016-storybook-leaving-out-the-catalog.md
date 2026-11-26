# 0016 Leaving the catalog out of Storybook's badges

## Why

Changing one catalog page badges only the pages whose own code changed, not every page whose test opens the catalog. So New still points testers at the latest work.

## Measurement

acceptances whose coverage lists no catalog file

-

acceptances in the coverage map

## Requirements

1. The map leaves out catalog folders
   1. GIVEN App maintainer keeps catalog pages and a helper in one folder
   2. GIVEN beside screens holding their own page or a #Preview
      1. WHEN the StorybookCoverage tool maps the repo
         1. THEN it leaves out that folder and keeps both screens and the package's own code
2. An exclude names a folder
   1. GIVEN App maintainer keeps a catalog helper where the rule misses it
      1. WHEN the StorybookCoverage tool maps the repo with --exclude naming its folder
         1. THEN it leaves out that folder's files
         2. THEN none whose name only starts the same way
