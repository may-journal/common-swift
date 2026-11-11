package requirements

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// appManifest is a maintainer's app package. It takes common-swift by a URL
// and a version tag, and links only Storybook into the app's own library.
const appManifest = `// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "DiaryApp",
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [.library(name: "DiaryKit", type: .dynamic, targets: ["DiaryKit"])],
    dependencies: [.package(url: %q, from: "1.0.0")],
    targets: [.target(name: "DiaryKit", dependencies: [.product(name: "Storybook", package: "common-swift")])]
)
`

// diarySource is the app's code: it imports Storybook and keeps the catalog
// behind the default gate.
const diarySource = `import Storybook

@MainActor public func diaryStorybook() -> StorybookAvailability {
    StorybookAvailability(gate: .debugOnly)
}
`

// storybookApp builds the maintainer's app against a clone of this repo
// tagged 1.0.0, reached by a file:// URL as an app reaches the release. It
// returns the app's folder, what the build printed and its exit code.
func storybookApp(t *testing.T) (string, string, int) {
	t.Helper()
	release := filepath.Join(t.TempDir(), "common-swift")
	git(t, filepath.Dir(release), "clone", "-q", checkoutWithTests(t), release)
	git(t, release, "tag", "1.0.0")
	app := t.TempDir()
	write(t, app, map[string]string{
		"Package.swift":                fmt.Sprintf(appManifest, "file://"+release),
		"Sources/DiaryKit/Diary.swift": diarySource,
	})
	out, code := run(t, app, nil, "swift", "build", "--product", "DiaryKit")
	return app, out, code
}

func Test0009_1(t *testing.T) {
	t.Parallel()
	_, out, code := storybookApp(t)
	sees(t, out, code, 0, "Build complete")
}

func Test0009_2(t *testing.T) {
	t.Parallel()
	app, out, code := storybookApp(t)
	if code != 0 {
		t.Fatalf("the app did not build, exit code %d:\n%s", code, out)
	}
	library := filepath.Join(app, ".build", "debug", "libDiaryKit.dylib")
	if _, err := os.Stat(library); err != nil {
		t.Fatalf("the build left no app library: %v", err)
	}
	links, _ := run(t, app, nil, "otool", "-L", library)
	if strings.Contains(links, "StoreKit") {
		t.Errorf("an app that picks only Storybook links StoreKit:\n%s", links)
	}
}
