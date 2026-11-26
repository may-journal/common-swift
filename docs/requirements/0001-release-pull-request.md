# 0001 Release pull request

## Why

Every merge to main feeds one release pull request, so I never write a version by hand. Release Please builds it from the conventional commits that the commit hook and pr-check hold me to.

## Measurement

merges to main that Release Please adds to the release pull request

-

merges to main

## Requirements

1. Only Release Please runs
   1. GIVEN Contributor merges a pull request into main
      1. WHEN GitHub starts the workflows for that push
         1. THEN only Release Please runs
         2. THEN through the shared workflow
