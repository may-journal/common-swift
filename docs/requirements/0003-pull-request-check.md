# 0003 Pull request check

## Why

pr-check holds each pull request to a conventional title and its own linked `changelog/` entry file. The release pull request writes `CHANGELOG.md` instead, needs no entry, and still passes.

## Measurement

merged pull requests that pass pr-check

-

merged pull requests

## Requirements

- 0003.1
  - Given Contributor opens a pull request whose title is not a conventional commit
    - When pr-check judges it
      - Then it fails naming the title
- 0003.2
  - Given Contributor opens a pull request whose description does not link its entry
    - When pr-check judges it
      - Then it fails asking for the link
- 0003.3
  - Given Contributor sees the release pull request, which changes `CHANGELOG.md` and adds no entry
    - When pr-check judges it
      - Then it passes
