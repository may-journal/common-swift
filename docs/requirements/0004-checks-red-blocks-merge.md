# 0004 Red checks block the change

## Why

A change with a red check never reaches main. Fitness runs on my commit, and the Fitness suite runs it again, with the build and the tests, on every pull request.

## Measurement

changes merged with every check green

-

changes merged

## Requirements

- 0004.1
  - Given Contributor commits with a subject that is not a conventional commit
    - When the commit hook runs
      - Then the commit is refused
- 0004.2
  - Given Contributor commits a change with no `changelog/` entry file
    - When the commit hook runs
      - Then the commit is refused
- 0004.3
  - Given Contributor commits a change with a broken link
    - When the commit hook runs
      - Then the commit is refused
- 0004.4
  - Given Contributor opens a pull request with a broken link
    - When the Fitness suite runs on it
      - Then the run fails
