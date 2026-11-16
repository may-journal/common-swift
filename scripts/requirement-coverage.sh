#!/usr/bin/env bash
# cspell:ignore coverprofile ltrimstr
# Maps each requirement acceptance to the repo source files its own test covers, which Storybook dates its pages from.
# Usage: scripts/requirement-coverage.sh [output], writing docs/requirements/coverage.json by default, with Xcode, go and jq.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd -P)"
output="${1:-$root/docs/requirements/coverage.json}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
pairs="$work/pairs.tsv"
: >"$pairs"

# The acceptance ID a test name stands for: test0006_3 and Test0006_3 both give 0006.3.
id_of() {
	local digits="${1#[Tt]est}"
	echo "${digits%%_*}.${digits#*_}"
}

# Prints "ID<TAB>path" for each covered file on stdin, or for the test's own file when none ran.
pair() {
	local id="$1" fallback="$2" covered
	covered="$(sort -u)"
	if [ -z "$covered" ]; then covered="$fallback"; fi
	while IFS= read -r file; do printf '%s\t%s\n' "$id" "$file"; done <<<"$covered" >>"$pairs"
}

# Swift: build each package's tests with coverage once, then run its requirement tests one by one.
for package in "$root"/Packages/*/ "$root/Examples/CommonSwiftDemo/DemoKit/"; do
	package="${package%/}"
	[ -d "$package/Tests" ] || continue
	tests="$(grep -rhoE 'func test[0-9]{4}_[0-9]+\(' "$package/Tests" | sed -E 's/func (.*)\(/\1/' | sort -u)"
	[ -n "$tests" ] || continue
	echo "Building ${package#"$root"/} with coverage" >&2
	swift build --package-path "$package" --build-tests --enable-code-coverage -q
	codecov="$(swift test --package-path "$package" --show-codecov-path)"
	for test in $tests; do
		file="$(grep -rlE "func $test\(" "$package/Tests" | head -1)"
		echo "  $test" >&2
		if ! swift test --package-path "$package" --skip-build --enable-code-coverage \
			--filter "$test\(" >"$work/log" 2>&1; then
			cat "$work/log" >&2
			echo "$test failed, so its coverage is unknown" >&2
			exit 1
		fi
		# The llvm-cov export swift test wrote: repo files with executed lines, leaving out tests and .build.
		jq -r --arg root "$root/" '.data[0].files[]
			| select(.summary.lines.covered > 0) | .filename
			| select(startswith($root)) | ltrimstr($root)
			| select(test("(^|/)(Tests|\\.build)/") | not)' "$codecov" |
			pair "$(id_of "$test")" "${file#"$root"/}"
	done
done

# Go: the requirement tests in requirements/, each alone with a coverage profile.
module="$(sed -nE 's/^module (.*)/\1/p' "$root/requirements/go.mod")"
tests="$(grep -hoE '^func Test[0-9]{4}_[0-9]+\(' "$root"/requirements/*_test.go | sed -E 's/func (.*)\(/\1/' | sort -u)"
for test in $tests; do
	file="$(grep -lE "^func $test\(" "$root"/requirements/*_test.go | head -1)"
	echo "  $test" >&2
	if ! go test -C "$root/requirements" -count=1 -run "^$test\$" -coverprofile="$work/go.out" . \
		>"$work/log" 2>&1; then
		cat "$work/log" >&2
		echo "$test failed, so its coverage is unknown" >&2
		exit 1
	fi
	# Profile lines read "module/path.go:1.2,3.4 statements count"; a count above 0 ran.
	awk 'NR > 1 && $NF > 0 { sub(/:.*/, "", $1); print $1 }' "$work/go.out" |
		sed "s|^$module/|requirements/|" | { grep -v '_test\.go$' || true; } |
		pair "$(id_of "$test")" "${file#"$root"/}"
done

# Sorted IDs and paths, so the same code always writes the same bytes.
jq -R -n --indent 2 -S '[inputs | split("\t")] | group_by(.[0])
	| map({key: .[0][0], value: (map(.[1]) | unique)}) | from_entries' "$pairs" >"$output"
echo "Wrote ${output#"$root"/}: $(jq length "$output") acceptances" >&2
