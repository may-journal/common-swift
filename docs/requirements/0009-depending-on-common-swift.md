# 0009 Depending on common-swift

## Why

My app takes every shared package from one repo URL and one version tag, and links only the products I pick.

## Measurement

apps that build with only the products they pick from common-swift

-

apps that depend on common-swift

## Requirements

- 0009.1
  - Given App maintainer adds common-swift by its URL and a version tag
    - When the app imports Storybook and builds
      - Then the build succeeds
- 0009.2
  - Given App maintainer picks only the Storybook product
    - When the app builds
      - Then it links no StoreKit
