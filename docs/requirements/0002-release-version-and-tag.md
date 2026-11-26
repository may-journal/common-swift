# 0002 Version and tag

## Why

Merging the release pull request is the one step that sets the version, the tag and `CHANGELOG.md`. No other workflow edits them.

## Measurement

releases whose version, tag and `CHANGELOG.md` come only from the release pull request

-

releases

## Requirements

1. Disagreeing version files fail
   1. GIVEN Contributor has a release pull request whose manifest and `version.txt` disagree
      1. WHEN fitness checks the release files
         1. THEN it fails naming `version.txt`
2. Merging writes the changelog and tag
   1. GIVEN Contributor merges the release pull request
      1. WHEN Release Please reads its config
         1. THEN it writes `CHANGELOG.md` and a plain `vX.Y.Z` tag
3. Other workflows leave main alone
   1. GIVEN Contributor has every other workflow in the repo
      1. WHEN GitHub runs one
         1. THEN it writes no file of main
         2. THEN at most merging a pull request the owner approved or completing Dependabot's pull request
