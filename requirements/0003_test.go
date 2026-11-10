package requirements

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

func Test0003_1(t *testing.T) {
	t.Parallel()
	pr := readmePR(t)
	pr.title = "Say what the packages are for"
	out, code := prCheck(t, checkout(t), pr)
	sees(t, out, code, 1, "Say what the packages are for", "type(scope): description")
}

func Test0003_2(t *testing.T) {
	t.Parallel()
	pr := readmePR(t)
	pr.body = prBody("- Docs: the README says what the packages are for.")
	out, code := prCheck(t, checkout(t), pr)
	sees(t, out, code, 1, "no changelog/ entry link", entryPath)
}

func Test0003_3(t *testing.T) {
	t.Parallel()
	repo := checkout(t)
	out, code := prCheck(t, repo, releasePR(t, repo))
	sees(t, out, code, 0, "Passed.")
}

// trackingIssue is the issue the release pull request closes. The shared
// release workflow opens it, since pr-check wants every PR to close one.
const trackingIssue = 24

// releasePR is the release pull request Release Please opens from this
// repo's config, its notes shaped as the shared release workflow does. It
// changes CHANGELOG.md, version.txt and the manifest, and no entry file.
func releasePR(t *testing.T, repo string) pullRequest {
	t.Helper()
	var config struct {
		Packages map[string]struct {
			Header string `json:"pull-request-header"`
			Footer string `json:"pull-request-footer"`
		} `json:"packages"`
	}
	raw, err := os.ReadFile(filepath.Join(repo, "release-please-config.json"))
	mustDo(t, err)
	mustDo(t, json.Unmarshal(raw, &config))
	root := config.Packages["."]
	notes := "### 1.0.0 (2026-11-10)\n\n\n### Documentation\n\n* readme: say what the packages are for\n"
	return pullRequest{
		number: 23,
		title:  "chore(main): release 1.0.0",
		body:   root.Header + "\n---\n\n\n" + notes + "\n---\n" + root.Footer + "\n\nCloses #24.",
		closes: map[int]issue{trackingIssue: {Body: "Release Please owns the version and notes in #23."}},
	}
}
