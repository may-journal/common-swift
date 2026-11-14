# Repo tasks. Run: make demo, make demo-test, make demo-install DEVICE=<udid>
#
# The demo app in Examples/CommonSwiftDemo shows every package; its README section says more.

DEMO = Examples/CommonSwiftDemo
DEMO_PROJECT = $(DEMO)/CommonSwiftDemo.xcodeproj

.PHONY: demo demo-test demo-install

# Build the demo for any iPhone and for the Mac without signing credentials, as a fresh clone would.
# The project signs with the owner's team; CODE_SIGNING_ALLOWED=NO on the command line turns that off.
demo:
	xcodegen generate --spec $(DEMO)/project.yml
	xcodebuild build -project $(DEMO_PROJECT) -scheme CommonSwiftDemo -configuration Debug \
		-destination generic/platform=iOS -derivedDataPath .build/demo CODE_SIGNING_ALLOWED=NO
	xcodebuild build -project $(DEMO_PROJECT) -scheme CommonSwiftDemo -configuration Debug \
		-destination platform=macOS -derivedDataPath .build/demo CODE_SIGNING_ALLOWED=NO

# Run the demo's requirement tests on the Mac.
demo-test:
	swift test --package-path $(DEMO)/DemoKit

# Sign the demo with the project's team, then install and launch it on one paired device,
# registering the device with the team when it is new. List devices with `xcrun devicectl list devices`.
DEMO_APP = .build/demo-device/Build/Products/Debug-iphoneos/CommonSwiftDemo.app
demo-install:
	test -n "$(DEVICE)" || { echo "usage: make demo-install DEVICE=<udid>"; exit 2; }
	xcodegen generate --spec $(DEMO)/project.yml
	xcodebuild build -project $(DEMO_PROJECT) -scheme CommonSwiftDemo \
		-configuration Debug -destination id=$(DEVICE) -derivedDataPath .build/demo-device \
		-allowProvisioningUpdates -allowProvisioningDeviceRegistration
	xcrun devicectl device install app --device $(DEVICE) $(DEMO_APP)
	xcrun devicectl device process launch --device $(DEVICE) \
		"$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $(DEMO_APP)/Info.plist)"
