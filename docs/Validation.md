# Validation — drawing course

## Expanded course, build 6 — 17 October 2026

Build 5 passed 8 unit tests and 5 UI workflows on iPhone 17 Pro Max (iOS 26.5) and iPad Pro 13-inch M5 (iPadOS 26.5). Build 6 passed the same 8 unit tests and 5 UI workflows on both devices on 17 October 2026, with zero failures. The UI suites completed at 00:06:15 (phone) and 00:06:17 (tablet), Europe/Bucharest. Xcode’s result-bundle finalization may finish later.

The curriculum check requires 100 unique lesson IDs/titles, 12 chapters, 100 full workshops, at least 330 reading words per lesson, and 100 decodable bundled images with distinct SHA-256 hashes. It also checks one-to-one lesson/reference matching. Storage tests cover personal-photo and reference-choice persistence, drawing persistence, failed writes, corrupt-file preservation, completion, and canonical coordinates.

UI coverage includes long reading through the final lesson’s demonstration, troubleshooting and independent assignment; gallery observation tools and navigation to practice/Studio; native drawing, undo/redo, reflection, completion and journal relaunch; onboarding/bookmarks; search and canvas setup.

Manual testing imported generated test photos through the native system picker into lessons and Studio on both devices. On build 6, a moved front image and an exposed portion of the image behind it were separately dragged: each moved only the selected visible layer. This verifies the transformed hit-area correction.

The signed Release archive for build 6 succeeded. Final media contains ten 1320 × 2868 iPhone screenshots and ten 2064 × 2752 iPad screenshots, visually reviewed as contact sheets. Headlines sit above real native captures. The reviewer-only video runs 185.6 seconds, accelerated 4× from a real build-5 recording; build 6 changes only the Studio hit-area placement relative to that course recording.

Physical Apple Pencil pressure/palm interaction and iOS 17 runtime behavior were not tested. There is no claim of expert endorsement, measured learning outcomes or automated art grading. Existing live privacy wording was not republished by this task.

## Initial 20-lesson validation (historical)

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

Apple Pencil pressure, palm interaction, physical-device rotation and iPad multitasking still need a hardware smoke test. iOS 17 is the compile-time minimum, but no iOS 17 simulator runtime was available for this validation. No signed archive, App Store Connect upload, review submission, website policy publication, or approval is implied by these checks. Those historical checks predate the expanded release; the final submission receipt records current media and submission status.

Final result bundles on the build host: `/tmp/draw-through-build6-phone-final.xcresult` and `/tmp/draw-through-build6-ipad-final.xcresult`. Signed archive: `/tmp/DrawThrough-Submission-Build6.xcarchive`; App Store upload reported **EXPORT SUCCEEDED** at 00:05:39.
