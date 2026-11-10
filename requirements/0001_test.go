package requirements

import (
	"slices"
	"testing"
)

// releaseCaller is the shared Release Please workflow the repo calls.
const releaseCaller = "may-journal/fitness-runner/.github/workflows/release-please-reusable.yml@v1"

func Test0001_1(t *testing.T) {
	t.Parallel()
	repo := checkout(t)
	started := startedByPush(t, repo, "main")
	if !slices.Equal(started, []string{"release-please.yml"}) {
		t.Fatalf("a push to main starts %q, want only release-please.yml", started)
	}
	for name, j := range workflows(t, repo)["release-please.yml"].Jobs {
		if j.Uses != releaseCaller || j.Secrets != "inherit" {
			t.Errorf("job %s calls %q with secrets %v, want %s with inherited secrets", name, j.Uses, j.Secrets, releaseCaller)
		}
	}
}
