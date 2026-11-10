package requirements

import (
	"os"
	"path"
	"path/filepath"
	"slices"
	"testing"

	"gopkg.in/yaml.v3"
)

// workflow is one file under .github/workflows as GitHub reads it.
type workflow struct {
	file        string
	On          any            `yaml:"on"`
	Permissions any            `yaml:"permissions"`
	Jobs        map[string]job `yaml:"jobs"`
}

// job is one job of a workflow: the reusable workflow it calls, the secrets
// it hands over, and the token permissions it grants.
type job struct {
	Uses        string `yaml:"uses"`
	Secrets     any    `yaml:"secrets"`
	Permissions any    `yaml:"permissions"`
}

// workflows reads every workflow GitHub runs in repo, keyed by file name.
func workflows(t *testing.T, repo string) map[string]workflow {
	t.Helper()
	files, err := filepath.Glob(filepath.Join(repo, ".github", "workflows", "*.yml"))
	mustDo(t, err)
	found := map[string]workflow{}
	for _, file := range files {
		raw, err := os.ReadFile(file)
		mustDo(t, err)
		w := workflow{file: filepath.Base(file)}
		mustDo(t, yaml.Unmarshal(raw, &w))
		found[w.file] = w
	}
	return found
}

// startedByPush names the workflows GitHub starts for a push to branch. Each
// has push in its `on`, with no branch filter or one that branch matches.
func startedByPush(t *testing.T, repo, branch string) []string {
	t.Helper()
	var started []string
	for name, w := range workflows(t, repo) {
		if pushes(w.On, branch) {
			started = append(started, name)
		}
	}
	slices.Sort(started)
	return started
}

// pushes reports whether an `on` value, a name, a list or a map, starts the
// workflow for a push to branch.
func pushes(on any, branch string) bool {
	switch v := on.(type) {
	case string:
		return v == "push"
	case []any:
		return slices.Contains(v, any("push"))
	case map[string]any:
		push, ok := v["push"]
		return ok && branchMatches(push, branch)
	}
	return false
}

// branchMatches applies a push trigger's branches and branches-ignore
// filters to branch. A trigger with only tag filters never runs for a branch.
func branchMatches(push any, branch string) bool {
	filters, _ := push.(map[string]any)
	if ignore, ok := filters["branches-ignore"]; ok {
		return !anyMatch(ignore, branch)
	}
	if only, ok := filters["branches"]; ok {
		return anyMatch(only, branch)
	}
	_, tags := filters["tags"]
	return !tags
}

// anyMatch reports whether one of a filter's glob patterns matches branch.
func anyMatch(patterns any, branch string) bool {
	list, _ := patterns.([]any)
	return slices.ContainsFunc(list, func(p any) bool {
		pattern, _ := p.(string)
		ok, _ := path.Match(pattern, branch)
		return ok
	})
}
