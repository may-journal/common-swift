# 0021 Mapping Go requirement tests in Storybook's coverage

## Why

An app's requirement tests may be Go tests beside its Swift code. The coverage step must not run them, since a Go test needs no build. Each still gets a badge, dated by its own file.

## Measurement

Go requirement tests that the coverage map lists by their own file

-

Go requirement tests in apps that show Storybook badges

## Requirements

1. Go
   1. GIVEN App maintainer keeps Go requirement tests in a module with no Go code besides its tests
      1. WHEN the StorybookCoverage tool maps the repo
         1. THEN it runs none of them
         2. THEN each maps to its own file
