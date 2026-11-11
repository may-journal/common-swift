package requirements

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"syscall"
	"testing"
)

// TestMain lets this test binary stand in for gh, and for the installer the
// hooks call, which then starts the resolved fitness.
func TestMain(m *testing.M) {
	switch filepath.Base(os.Args[0]) {
	case "gh":
		os.Exit(replay(os.Args[1:]))
	case "fitness-install":
		os.Exit(installed(os.Args[1:]))
	}
	os.Exit(m.Run())
}

// installed runs the resolved fitness with the arguments after the
// installer's `--`, as the installer itself hands them over.
func installed(args []string) int {
	at := slices.Index(args, "--")
	if at < 0 {
		fmt.Fprintf(os.Stderr, "fitness-install stand-in: only runs fitness after --, got %q\n", args)
		return 98
	}
	bin := os.Getenv(fitnessEnv)
	err := syscall.Exec(bin, append([]string{"fitness"}, args[at+1:]...), os.Environ())
	fmt.Fprintf(os.Stderr, "fitness-install stand-in: cannot start %s: %v\n", bin, err)
	return 98
}

// response is one saved gh answer: a call whose last argument is Path, the
// API path it reads, gets Stdout.
type response struct {
	Path   string `json:"path"`
	Stdout string `json:"stdout"`
}

// replayEnv names the folder holding the saved answers.
const replayEnv = "REQUIREMENTS_REPLAY"

// replay answers one gh call from the saved response for its path. A call
// with no saved answer fails, so a test never reaches GitHub.
func replay(args []string) int {
	var saved []response
	raw, _ := os.ReadFile(filepath.Join(os.Getenv(replayEnv), "gh.json"))
	_ = json.Unmarshal(raw, &saved)
	for _, r := range saved {
		if len(args) > 0 && args[len(args)-1] == r.Path {
			fmt.Print(r.Stdout)
			return 0
		}
	}
	fmt.Fprintf(os.Stderr, "gh stand-in: no saved response for: %s\n", strings.Join(args, " "))
	return 97
}

// standIns links this test binary as gh and fitness-install in a fresh
// folder and saves the answers for gh. It returns the environment that puts
// them first.
func standIns(t *testing.T, gh []response) []string {
	t.Helper()
	self, err := os.Executable()
	mustDo(t, err)
	bin, dir := t.TempDir(), t.TempDir()
	for _, name := range []string{"gh", "fitness-install"} {
		mustDo(t, os.Symlink(self, filepath.Join(bin, name)))
	}
	data, err := json.Marshal(gh)
	mustDo(t, err)
	mustDo(t, os.WriteFile(filepath.Join(dir, "gh.json"), data, 0o644))
	return []string{
		"PATH=" + bin + string(os.PathListSeparator) + os.Getenv("PATH"),
		"FITNESS_INSTALL_DIR=" + bin,
		replayEnv + "=" + dir,
		fitnessEnv + "=" + fitnessBinary(t),
	}
}

// repoSlug is the repository GitHub runs pr-check for.
const repoSlug = "may-journal/common-swift"

// prEvent saves the pull_request event GitHub hands pr-check for pull
// request number, and returns the Actions environment that names it.
func prEvent(t *testing.T, number int, title, body string) []string {
	t.Helper()
	pr := map[string]any{"number": number, "title": title, "body": body}
	data, err := json.Marshal(map[string]any{"action": "opened", "pull_request": pr})
	mustDo(t, err)
	path := filepath.Join(t.TempDir(), "event.json")
	mustDo(t, os.WriteFile(path, data, 0o644))
	return []string{"GITHUB_EVENT_NAME=pull_request", "GITHUB_EVENT_PATH=" + path, "GITHUB_REPOSITORY=" + repoSlug}
}

// pullRequest is a pull request as GitHub holds it: its title, description,
// every file it changes, and the issues its description closes.
type pullRequest struct {
	number int
	title  string
	body   string
	files  []changedFile
	closes map[int]issue
}

// changedFile is one file a pull request changes, as GitHub lists it.
type changedFile struct {
	Filename string `json:"filename"`
	Status   string `json:"status"`
	Patch    string `json:"patch"`
}

// issue is one issue's description and labels.
type issue struct {
	Body   string   `json:"body"`
	Labels []string `json:"labels"`
}

// entryFiles is what GitHub prints for the read of pr's files that pr-check
// makes: its jq filter keeps the files directly under changelog/.
func (pr pullRequest) entryFiles(t *testing.T) string {
	t.Helper()
	var out strings.Builder
	for _, f := range pr.files {
		if filepath.Dir(f.Filename) != "changelog" {
			continue
		}
		line, err := json.Marshal(f)
		mustDo(t, err)
		out.Write(append(line, '\n'))
	}
	return out.String()
}

// answers are the saved replies to each read pr-check makes of pr. They hold
// the pull request, its files, its issues, and no release yet.
func (pr pullRequest) answers(t *testing.T) []response {
	t.Helper()
	view, err := json.Marshal(map[string]any{"number": pr.number, "title": pr.title, "body": pr.body})
	mustDo(t, err)
	pulls := fmt.Sprintf("repos/%s/pulls/%d", repoSlug, pr.number)
	saved := []response{
		{Path: pulls + "/files?per_page=100", Stdout: pr.entryFiles(t)},
		{Path: pulls, Stdout: string(view) + "\n"},
		{Path: "repos/" + repoSlug + "/releases?per_page=1"},
	}
	for n, i := range pr.closes {
		data, err := json.Marshal(i)
		mustDo(t, err)
		saved = append(saved, response{Path: fmt.Sprintf("repos/%s/issues/%d", repoSlug, n), Stdout: string(data) + "\n"})
	}
	return saved
}

// prCheck runs fitness pr-check in repo as GitHub runs it for pr, with gh
// answering from pr. It returns what it printed and its exit code.
func prCheck(t *testing.T, repo string, pr pullRequest) (string, int) {
	t.Helper()
	env := append(standIns(t, pr.answers(t)), prEvent(t, pr.number, pr.title, pr.body)...)
	return run(t, repo, env, fitnessBinary(t), "pr-check")
}
