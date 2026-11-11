# 0005 One test per acceptance

## Why

Every root requirement is proven by one test that runs the repo as I do, so a promise with no test is caught.

## Measurement

acceptances owned by exactly one test

-

acceptances

## Requirements

- 0005.1
  - Given Contributor adds an acceptance with no test
    - When fitness runs the requirements check
      - Then it fails naming the missing test
