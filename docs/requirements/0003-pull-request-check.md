# 0003 Pull request check

## Why

pr-check holds each pull request to a conventional title and its own linked `changelog/` entry file. The release pull request writes `CHANGELOG.md` instead, needs no entry, and still passes.

## Measurement

merged pull requests that pass pr-check

-

merged pull requests

## Requirements

1. Titles must be conventional commits
   1. GIVEN Contributor opens a pull request whose title is not a conventional commit
      1. WHEN pr-check judges it
         1. THEN it fails naming the title
2. Descriptions must link their entry
   1. GIVEN Contributor opens a pull request whose description does not link its entry
      1. WHEN pr-check judges it
         1. THEN it fails asking for the link
3. The release pull request needs no entry
   1. GIVEN Contributor sees the release pull request
   2. GIVEN which changes `CHANGELOG.md`
   3. GIVEN which adds no entry
      1. WHEN pr-check judges it
         1. THEN it passes
