# 0002 Version and tag

## Why

Merging the release pull request is the one step that sets the version, the tag and `CHANGELOG.md`. No other workflow edits them.

## Measurement

releases whose version, tag and `CHANGELOG.md` come only from the release pull request

-

releases

## Requirements

- 0002.1
  - Given Contributor has a release pull request whose manifest and `version.txt` disagree
    - When fitness checks the release files
      - Then it fails naming `version.txt`
- 0002.2
  - Given Contributor merges the release pull request
    - When Release Please reads its config
      - Then it writes `CHANGELOG.md` and a plain `vX.Y.Z` tag
- 0002.3
  - Given Contributor has every other workflow in the repo
    - When GitHub runs one
      - Then it cannot write the version, the tag or `CHANGELOG.md`
