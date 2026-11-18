# Repo tasks. Run: make demo, make demo-test, make coverage, make demo-install DEVICE=<udid>
#
# The demo app in Examples/CommonSwiftDemo shows every package; its README section says more.

DEMO = Examples/CommonSwiftDemo
DEMO_PROJECT = $(DEMO)/CommonSwiftDemo.xcodeproj

.PHONY: demo demo-test coverage demo-install

# Write the untracked coverage map, so a build dates each Storybook badge by the code its test covers.
# It is the StorybookCoverage step apps run, and skips itself when the map is current for HEAD.
# The fast demo build skips it, and its badges date by each test's file instead.
coverage:
	swift run -q storybook-coverage

# Build the demo for any iPhone and for the Mac without signing credentials, as a fresh clone would.
# The project signs with the owner's team; CODE_SIGNING_ALLOWED=NO on the command line turns that off.
demo:
	xcodegen generate --spec $(DEMO)/project.yml
	xcodebuild build -project $(DEMO_PROJECT) -scheme CommonSwiftDemo -configuration Debug \
		-destination generic/platform=iOS -derivedDataPath .build/demo CODE_SIGNING_ALLOWED=NO -skipPackagePluginValidation
	xcodebuild build -project $(DEMO_PROJECT) -scheme CommonSwiftDemo -configuration Debug \
		-destination platform=macOS -derivedDataPath .build/demo CODE_SIGNING_ALLOWED=NO -skipPackagePluginValidation

# Run the demo's requirement tests on the Mac.
demo-test:
	swift test --package-path $(DEMO)/DemoKit

# Sign the demo with the project's team, then install and launch it on one paired device,
# registering the device with the team when it is new. List devices with `xcrun devicectl list devices`.
# It writes the coverage map first, so the device shows real badge ages.
DEMO_APP = .build/demo-device/Build/Products/Debug-iphoneos/CommonSwiftDemo.app
demo-install:
	test -n "$(DEVICE)" || { echo "usage: make demo-install DEVICE=<udid>"; exit 2; }
	$(MAKE) coverage
	xcodegen generate --spec $(DEMO)/project.yml
	xcodebuild build -project $(DEMO_PROJECT) -scheme CommonSwiftDemo \
		-configuration Debug -destination id=$(DEVICE) -derivedDataPath .build/demo-device \
		-allowProvisioningUpdates -allowProvisioningDeviceRegistration
	xcrun devicectl device install app --device $(DEVICE) $(DEMO_APP)
	xcrun devicectl device process launch --device $(DEVICE) \
		"$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $(DEMO_APP)/Info.plist)"
