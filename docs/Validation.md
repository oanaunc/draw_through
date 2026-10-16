# Validation — learning revision

16 October 2026, Xcode 27.0. Deployment target remains iOS 17.0.

| Check | Result |
| --- | --- |
| iPhone 17 Pro simulator, iOS 26.5 | 7 storage/curriculum tests and 3 UI workflows passed |
| iPad Pro 13-inch simulator, iPadOS 26.5 | 3 UI workflows passed; final drawing-storage and resize regression suite: 7 passed |
| iPhone 18 Pro simulator, iOS 27.0 | Final storage/resize suite: 7 passed; 3 UI workflows passed |
| Generic iOS device, Release configuration | Build succeeded with signing disabled |
| Bundled privacy manifest | Plist validation passed; included in Release app bundle |
| Release build identity | Existing bundle ID; CFBundleVersion 2 |
| Repository whitespace check | `git diff --check` passed |

The seven unit tests cover the 20-lesson curriculum, bookmark and drawing persistence across store recreation, reflections, completion requiring marks, completion preserved on revisiting, failed writes not awarding progress, corrupt files preserved and reported, and canonical drawing coordinates during load and resize. Loading before an explicit layout is covered by the resize test.

The three UI workflows cover onboarding pages and saved-lesson filtering; drawing, undo/redo, guidance, reflection entry, completion, journal access, app relaunch, and reopening a saved drawing; and lesson search plus access to the existing Studio and canvas setup. Drawings in screenshots are actual test strokes on the live practice pad.

## Reproduce

Open the project in Xcode, select the shared DrawThrough scheme and an available iPhone or iPad simulator, then run Product > Test. The scheme includes both test targets.

For command-line runs, use your simulator's actual device name or ID:

```sh
xcodebuild -project DrawThrough.xcodeproj -scheme DrawThrough \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  CODE_SIGNING_ALLOWED=NO test

xcodebuild -project DrawThrough.xcodeproj -scheme DrawThrough \
  -destination 'generic/platform=iOS' -configuration Release \
  CODE_SIGNING_ALLOWED=NO build
```

Use `-only-testing:DrawThroughTests` or `-only-testing:DrawThroughUITests` to run either suite separately.

## Visual evidence and limits

Current QA captures are in `docs/screenshots/`, for iPhone and iPad: Learn, a lesson page, the drawing pad, and the journal. The layouts were inspected. They show real application screens and stored drawings rather than a promotional-only implementation.

Simulator runs emitted transient “Invalid frame dimension” warnings when the system text keyboard appeared, while the affected UI tests completed successfully. No persistent clipping was found in the inspected screenshots. These logs do not establish behavior on physical hardware.

Apple Pencil pressure, palm interaction, physical-device rotation and iPad multitasking still need a hardware smoke test. iOS 17 is the compile-time minimum, but no iOS 17 simulator runtime was available for this validation. No signed archive, App Store Connect upload, review submission, website policy publication, or approval is implied by these checks. Refresh required storefront screenshots and publish the prepared privacy wording before submitting.
