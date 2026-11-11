# 0001 Release pull request

## Why

Every merge to main feeds one release pull request, so I never write a version by hand. Release Please builds it from the conventional commits that the commit hook and pr-check hold me to.

## Measurement

merges to main that Release Please adds to the release pull request

-

merges to main

## Requirements

- 0001.1
  - Given Contributor merges a pull request into main
    - When GitHub starts the workflows for that push
      - Then only Release Please runs, through the shared workflow
