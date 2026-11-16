#!/usr/bin/env bash
# Usage: scripts/requirement-coverage.sh [output] runs the StorybookCoverage tool, writing docs/requirements/coverage.json.
# git ignores that map, so a build that needs real badge ages runs this first, as make demo-install does.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd -P)"
exec swift run --package-path "$root/Packages/Storybook" -q storybook-coverage --root "$root" "$@"
