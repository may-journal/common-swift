# 0009 Depending on common-swift

## Why

My app takes every shared package from one repo URL and one version tag, and links only the products I pick.

## Measurement

apps that build with only the products they pick from common-swift

-

apps that depend on common-swift

## Requirements

1. The package builds from its URL
   1. GIVEN App maintainer adds common-swift by its URL and a version tag
      1. WHEN the app imports Storybook and builds
         1. THEN the build succeeds
2. Storybook alone links no StoreKit
   1. GIVEN App maintainer picks only the Storybook product
      1. WHEN the app builds
         1. THEN the app's own library links no StoreKit
