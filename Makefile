# Repo tasks. Run: make hooks, make fitness, make format, make requirements

FITNESS_INSTALL = $(HOME)/.local/share/fitness/fitness-install

.PHONY: hooks fitness format requirements

# Use the org-synced hooks in .fitness-hooks, once the org sync adds them.
hooks:
	git config --local core.hooksPath .fitness-hooks

# Run the full fitness suite, as CI does.
fitness:
	"$(FITNESS_INSTALL)" --version latest

# Wrap and indent every Swift file with the toolchain's swift-format, per .swift-format.
format:
	swift format format --in-place --recursive --configuration .swift-format Sources Tests Package.swift

# Build every package and run every requirement test on the Mac.
requirements:
	swift test
