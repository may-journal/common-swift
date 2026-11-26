# 0004 Red checks block the change

## Why

A change with a red check never reaches main. Fitness runs on my commit, and the Fitness suite runs it again, with the build and the tests, on every pull request.

## Measurement

changes merged with every check green

-

changes merged

## Requirements

1. Commit subjects must be conventional
   1. GIVEN Contributor commits with a subject that is not a conventional commit
      1. WHEN the commit hook runs
         1. THEN the commit is refused
2. Commits need a changelog entry
   1. GIVEN Contributor commits a change with no `changelog/` entry file
      1. WHEN the commit hook runs
         1. THEN the commit is refused
3. Commits refuse broken links
   1. GIVEN Contributor commits a change with a broken link
      1. WHEN the commit hook runs
         1. THEN the commit is refused
4. Pull requests refuse broken links
   1. GIVEN Contributor opens a pull request with a broken link
      1. WHEN the Fitness suite runs on it
         1. THEN the run fails
