package requirements

import "testing"

// committed writes files over a checkout with the hooks on and commits them
// with subject. It returns what git printed and its exit code.
func committed(t *testing.T, subject string, files ...map[string]string) (string, int) {
	t.Helper()
	repo := checkout(t)
	hooks(t, repo)
	for _, f := range files {
		write(t, repo, f)
	}
	git(t, repo, "add", "-A")
	return run(t, repo, standIns(t, nil), "git", "commit", "-q", "-m", subject)
}

// subject is the readme change's conventional commit subject.
const subject = "docs(readme): say what the packages are for"

func Test0004_1(t *testing.T) {
	t.Parallel()
	out, code := committed(t, "Say what the packages are for", readme, entry)
	sees(t, out, code, 1, "semantic-commit", "Say what the packages are for")
}

func Test0004_2(t *testing.T) {
	t.Parallel()
	out, code := committed(t, subject, readme)
	sees(t, out, code, 1, "changelog-updated", "Stage a changelog/")
}

// brokenLink is a change whose README links a page that does not exist,
// which the markdown-links check fails.
var brokenLink = map[string]string{"README.md": readme["README.md"] + "\nSee [setup](docs/setup.md) to start.\n"}

func Test0004_3(t *testing.T) {
	t.Parallel()
	out, code := committed(t, subject, brokenLink, entry)
	sees(t, out, code, 1, "markdown-links", "docs/setup.md")
}

func Test0004_4(t *testing.T) {
	t.Parallel()
	repo := checkout(t)
	git(t, repo, "switch", "-q", "-c", "readme")
	write(t, repo, brokenLink)
	write(t, repo, entry)
	git(t, repo, "add", "-A")
	git(t, repo, "commit", "-q", "-m", subject)
	pr := readmePR(t)
	env := append(standIns(t, pr.answers(t)), prEvent(t, pr.number, pr.title, pr.body)...)
	out, code := run(t, repo, append(env, "GITHUB_ACTIONS=true"), fitnessBinary(t))
	sees(t, out, code, 1, "markdown-links", "docs/setup.md")
}
