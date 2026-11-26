# 0005 One test per acceptance

## Why

Every root requirement is proven by one test that runs the repo as I do, so a promise with no test is caught.

## Measurement

acceptances owned by exactly one test

-

acceptances

## Requirements

1. A missing test fails
   1. GIVEN Contributor adds an acceptance with no test
      1. WHEN fitness runs the requirements check
         1. THEN it fails naming the missing test
