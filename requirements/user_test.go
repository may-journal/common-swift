// Package requirements proves docs/requirements as a contributor meets them.
// Each test copies the repo and runs git and fitness there as a contributor
// does. gh answers from saved responses.
package requirements

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"slices"
	"strings"
	"sync"
	"testing"
)

// readme is the change a contributor makes in most tests: the README says
// what the packages are for.
var readme = map[string]string{"README.md": "# common-swift\n\nShared Swift packages that the may-* iOS apps take by version.\n"}

// entryPath is the changelog entry file that change adds.
const entryPath = "changelog/2026-11-10-1800-readme-purpose.md"

// entry is that change's entry file, which shares its words.
var entry = map[string]string{entryPath: "### 2026.11.10.1800\n\n> The README says what the shared packages are for.\n\n" +
	"- Docs: the README says the iOS apps take the shared Swift packages by version.\n" +
	"- Docs: the README names the may-* apps as the ones that take the packages.\n" +
	"- Docs: the README keeps its one-line title for the shared packages.\n"}

// planNumber is the Plan the readme change closes, all of its boxes ticked.
const planNumber = 3

// prBody is a pull request description in the repo's template, closing the
// Plan, with changelog as its `## Changelog` bullet.
func prBody(changelog string) string {
	return "> The README says what the shared packages are for.\n\n## Background\n\n" +
		fmt.Sprintf("Stacks on no other pull request. Closes https://github.com/%s/issues/%d\n\n", repoSlug, planNumber) +
		"## Changelog\n\n" + changelog + "\n"
}

// entryLink is the `## Changelog` bullet that links the readme change's entry.
var entryLink = fmt.Sprintf("- [Changelog entry](https://github.com/%s/blob/readme/%s)", repoSlug, entryPath)

// readmePR is the readme change as a pull request. It has a conventional
// title, links its entry, and lists that entry file as GitHub does.
func readmePR(t *testing.T) pullRequest {
	t.Helper()
	var patch strings.Builder
	patch.WriteString("@@ -0,0 +1,7 @@\n")
	for _, line := range strings.SplitAfter(strings.TrimSuffix(entry[entryPath], "\n"), "\n") {
		patch.WriteString("+" + line)
	}
	return pullRequest{
		number: 21,
		title:  "docs(readme): say what the packages are for",
		body:   prBody(entryLink),
		files:  []changedFile{{Filename: entryPath, Status: "added", Patch: patch.String()}},
		closes: map[int]issue{planNumber: {Body: "> The README says what the packages are for.\n\n## What needs to happen\n\n- [x] Say what the packages are for\n", Labels: []string{"Plan"}}},
	}
}

// fitnessEnv names the fitness binary the fitness-install stand-in starts.
const fitnessEnv = "REQUIREMENTS_FITNESS"

var (
	resolveOnce sync.Once
	resolved    string
	resolveErr  error
)

// fitnessBinary is the fitness a contributor runs: the latest release the
// documented installer holds, else the one on PATH, as CI installs it.
func fitnessBinary(t *testing.T) string {
	t.Helper()
	resolveOnce.Do(func() { resolved, resolveErr = resolveFitness() })
	if resolveErr != nil {
		t.Fatalf("no fitness to run; install it as .github/fitness-setup.md says: %v", resolveErr)
	}
	return resolved
}

// installerPath is the installer the synced hooks run: fitness-install in
// FITNESS_INSTALL_DIR, or in its default folder.
func installerPath() string {
	dir := os.Getenv("FITNESS_INSTALL_DIR")
	if home, err := os.UserHomeDir(); dir == "" && err == nil {
		dir = filepath.Join(home, ".local", "share", "fitness")
	}
	return filepath.Join(dir, "fitness-install")
}

// resolveFitness asks that installer where the latest release lives, as the
// hooks do. Without an installer it takes fitness from PATH.
func resolveFitness() (string, error) {
	installer := installerPath()
	if _, err := os.Stat(installer); err != nil {
		return exec.LookPath("fitness")
	}
	out, err := exec.Command(installer, "--version", "latest", "--install-only").Output()
	lines := strings.Fields(string(out))
	if err != nil || len(lines) == 0 {
		return "", fmt.Errorf("%s --install-only printed no folder: %v", installer, err)
	}
	return filepath.Join(lines[len(lines)-1], "fitness"), nil
}

// checkout copies this repo's tracked files into a fresh repo on main and
// commits them, as a contributor's clone holds them. The requirement tests
// stay out of the copy, so a fitness run there never starts them again.
func checkout(t *testing.T) string {
	t.Helper()
	return clone(t, false)
}

// checkoutWithTests is checkout with the requirement tests copied too, for
// a check that reads them without running them.
func checkoutWithTests(t *testing.T) string {
	t.Helper()
	return clone(t, true)
}

// clone copies the tracked files, the requirement tests only when tests is
// set, and commits them on main.
func clone(t *testing.T, tests bool) string {
	t.Helper()
	repo := t.TempDir()
	out, err := exec.Command("git", "-C", "..", "ls-files", "-z").Output()
	mustDo(t, err)
	for _, name := range strings.Split(strings.TrimRight(string(out), "\x00"), "\x00") {
		if tests || !strings.HasPrefix(name, "requirements/") {
			copyFile(t, filepath.Join("..", name), filepath.Join(repo, name))
		}
	}
	git(t, repo, "init", "-q", "-b", "main")
	git(t, repo, "add", "-A")
	git(t, repo, "commit", "-q", "-m", "docs(readme): start from main")
	return repo
}

// copyFile copies one file, keeping its mode, so the hooks stay executable.
func copyFile(t *testing.T, from, to string) {
	t.Helper()
	info, err := os.Stat(from)
	mustDo(t, err)
	data, err := os.ReadFile(from)
	mustDo(t, err)
	mustDo(t, os.MkdirAll(filepath.Dir(to), 0o755))
	mustDo(t, os.WriteFile(to, data, info.Mode().Perm()))
}

// write puts each file into repo, creating folders as needed.
func write(t *testing.T, repo string, files map[string]string) {
	t.Helper()
	for name, body := range files {
		path := filepath.Join(repo, filepath.FromSlash(name))
		mustDo(t, os.MkdirAll(filepath.Dir(path), 0o755))
		mustDo(t, os.WriteFile(path, []byte(body), 0o644))
	}
}

// git runs one git command in repo, with hooks off, and fails the test if
// it fails. Contributor steps that run the hooks use run instead.
func git(t *testing.T, repo string, args ...string) {
	t.Helper()
	args = append([]string{"-c", "core.hooksPath=/dev/null"}, args...)
	if out, code := run(t, repo, nil, "git", args...); code != 0 {
		t.Fatalf("git %v exited %d:\n%s", args, code, out)
	}
}

// hooks turns on the synced hooks, as .github/fitness-setup.md tells a
// contributor to.
func hooks(t *testing.T, repo string) {
	t.Helper()
	git(t, repo, "config", "--local", "core.hooksPath", ".fitness-hooks")
}

// ansi matches terminal color codes, which a reader does not see as text.
var ansi = regexp.MustCompile(`\x1b\[[0-9;]*m`)

// run starts name in dir in a contributor's shell, with env added. It
// returns what it printed, color codes dropped, and its exit code.
func run(t *testing.T, dir string, env []string, name string, args ...string) (string, int) {
	t.Helper()
	cmd := exec.Command(name, args...)
	cmd.Dir, cmd.Env = dir, append(contributorEnv(t), env...)
	out, err := cmd.CombinedOutput()
	if cmd.ProcessState == nil {
		t.Fatalf("%s did not start: %v", name, err)
	}
	return ansi.ReplaceAllString(string(out), ""), cmd.ProcessState.ExitCode()
}

// runnerVars are the variable prefixes of whatever started the tests: its git,
// GitHub Actions and fitness settings, which a contributor's shell lacks.
var runnerVars = []string{"GIT_", "GITHUB_", "FITNESS_", "CI="}

// contributorEnv is the host's environment without runnerVars, and with a
// git identity of its own.
func contributorEnv(t *testing.T) []string {
	t.Helper()
	env := slices.DeleteFunc(os.Environ(), func(kv string) bool {
		return slices.ContainsFunc(runnerVars, func(p string) bool { return strings.HasPrefix(kv, p) })
	})
	global := filepath.Join(t.TempDir(), "gitconfig")
	mustDo(t, os.WriteFile(global, []byte("[user]\n\tname = Contributor\n\temail = contributor@example.com\n"), 0o644))
	return append(env, "GIT_CONFIG_GLOBAL="+global, "GIT_CONFIG_SYSTEM="+os.DevNull)
}

// sees fails the test unless the run exited with code and printed each of
// words.
func sees(t *testing.T, out string, code, want int, words ...string) {
	t.Helper()
	if code != want {
		t.Errorf("exit code %d, want %d; output:\n%s", code, want, out)
	}
	for _, w := range words {
		if !strings.Contains(out, w) {
			t.Errorf("output lacks %q:\n%s", w, out)
		}
	}
}

func mustDo(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatal(err)
	}
}
