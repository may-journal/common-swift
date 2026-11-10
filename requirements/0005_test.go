package requirements

import (
	"os"
	"path/filepath"
	"testing"
)

// untested0005 is an acceptance a contributor adds to a doc without a test.
const untested0005 = "- 0005.2\n  - Given Contributor adds a second acceptance\n    - When nobody writes its test\n      - Then fitness names it\n"

func Test0005_1(t *testing.T) {
	t.Parallel()
	repo := checkoutWithTests(t)
	doc := filepath.Join(repo, "docs", "requirements", "0005-checks-one-test-per-acceptance.md")
	raw, err := os.ReadFile(doc)
	mustDo(t, err)
	mustDo(t, os.WriteFile(doc, append(raw, untested0005...), 0o644))
	out, code := run(t, repo, standIns(t, nil), fitnessBinary(t), "requirements")
	sees(t, out, code, 1, "0005.2", "Test0005_2")
}
