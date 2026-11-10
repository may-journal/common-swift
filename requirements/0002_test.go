package requirements

import (
	"encoding/json"
	"os"
	"path/filepath"
	"slices"
	"testing"
)

func Test0002_1(t *testing.T) {
	t.Parallel()
	repo := checkout(t)
	write(t, repo, map[string]string{".release-please-manifest.json": `{".": "1.1.0"}` + "\n", "version.txt": "1.0.0\n"})
	out, code := run(t, repo, standIns(t, nil), fitnessBinary(t), "release-changelog")
	sees(t, out, code, 1, "release-changelog", "version.txt")
}

// releaseConfig is the root package of release-please-config.json, the part
// that decides what merging the release pull request writes.
type releaseConfig struct {
	VersionFile    string `json:"version-file"`
	ComponentInTag *bool  `json:"include-component-in-tag"`
	SkipChangelog  *bool  `json:"skip-changelog"`
	ChangelogPath  string `json:"changelog-path"`
}

// writesChangelog reports whether the release writes the root CHANGELOG.md.
func (c releaseConfig) writesChangelog() bool {
	return c.SkipChangelog != nil && !*c.SkipChangelog && c.ChangelogPath == ""
}

// plainTag reports whether the release tags vX.Y.Z, with no component, from
// version.txt.
func (c releaseConfig) plainTag() bool {
	return c.ComponentInTag != nil && !*c.ComponentInTag && c.VersionFile == "version.txt"
}

// packages reads the packages release-please-config.json releases in repo.
func packages(t *testing.T, repo string) map[string]releaseConfig {
	t.Helper()
	var config struct {
		Packages map[string]releaseConfig `json:"packages"`
	}
	raw, err := os.ReadFile(filepath.Join(repo, "release-please-config.json"))
	mustDo(t, err)
	mustDo(t, json.Unmarshal(raw, &config))
	return config.Packages
}

func Test0002_2(t *testing.T) {
	t.Parallel()
	released := packages(t, checkout(t))
	root := released["."]
	if len(released) != 1 || !root.writesChangelog() {
		t.Errorf("merging the release PR writes no root CHANGELOG.md: packages %v", released)
	}
	if !root.plainTag() {
		t.Errorf("the release tag is not a plain vX.Y.Z from version.txt: %+v", root)
	}
}

func Test0002_3(t *testing.T) {
	t.Parallel()
	want := []string{"release-please.yml release"}
	if got := writers(t, checkout(t)); !slices.Equal(got, want) {
		t.Errorf("jobs that can write the version, the tag or CHANGELOG.md: %q, want only %q", got, want)
	}
}

// writers names each workflow job in repo, as "file job", whose token can
// write the repo or that calls the shared Release Please.
func writers(t *testing.T, repo string) []string {
	t.Helper()
	var found []string
	for name, w := range workflows(t, repo) {
		for id, j := range w.Jobs {
			if w.canWrite(j) {
				found = append(found, name+" "+id)
			}
		}
	}
	slices.Sort(found)
	return found
}

// canWrite reports whether job j of w can write the repo. It can when it
// calls Release Please, or its permissions are unset or grant writes.
func (w workflow) canWrite(j job) bool {
	grants := j.Permissions
	if grants == nil {
		grants = w.Permissions
	}
	return grants == nil || writes(grants) || j.Uses == releaseCaller
}

// writes reports whether a permissions value lets the token write contents:
// write-all, or contents set to write.
func writes(permissions any) bool {
	if permissions == "write-all" {
		return true
	}
	grants, _ := permissions.(map[string]any)
	return grants["contents"] == "write"
}
