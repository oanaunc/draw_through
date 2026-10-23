# Draw Through — Android 1.0.0 (1)

Prepared on **23 October 2026**, Europe/Bucharest.

## Current release state

The Android app is implemented, tested and signed. The Google Play new-app form is prepared for **Draw Through**, free, English (United States), package `com.oanarinaldi.drawthrough`; Play confirmed that the package name is available. **The app has not yet been created, uploaded or submitted.** The app-creation/export declarations require the account owner's confirmation before continuing in Play Console.

The visible form is at https://play.google.com/console/u/0/developers/8359156760975569195/create-new-app?hl=en . No production approval or public availability is implied by the prepared bundle.

## Verification

| Check | Result |
|---|---|
| API 36 Pixel 7 emulator, 1080×2400 | 5 workflow tests passed, no failures |
| API 36 Pixel Tablet emulator, 2560×1600 | 5 workflow tests passed, no failures |
| Final phone/tablet content and layout checks | Passed after final spacing adjustments |
| Debug and release lint | Passed; advisory dependency/security-review warnings only |
| Signed, minified release AAB and APK | Build succeeded; APK signature verified |
| Signed release installation and launch | Passed on tablet; actual introduction captured |
| Bundled assets | All packaged web assets match source; all 100 course images match Apple originals byte for byte |
| Native shared libraries | None; no bundled native library page-alignment dependency |
| Store assets | 8 phone and 6 tablet screenshots, 512px icon, 1024×500 feature graphic |
| Public privacy policy | Android/course updates deployed successfully; live content verified |

The device tests exercise real touch drawing and real drag/pinch/rotation, undo/redo, completion, reflection and drawing persistence after Activity recreation, the complete catalog and images, observation tools, composition save/duplicate, preserved corrupt files, failed-write behavior, the real native photo picker and real MediaStore PNG export. Generated fixture images are used throughout.

Test reports are in `validation/`. `BundleVerification.json` records the signed AAB hash and byte size. The signed upload bundle is built locally at `android/app/build/outputs/bundle/release/app-release.aab`; binaries and private signing material are excluded from Git.

Store screenshots preserve complete genuine Android captures proportionally on a warm-paper canvas. `ScreenshotManifest.json` records source/output hashes. `raw-phone/` and `raw-tablet/` retain the actual device captures; the store upload directories are `screenshots-phone/` and `screenshots-tablet/`.

## Content and visual scope

All 100 lessons, workshops and course references, all 12 chapters and the three introduction images are included. Apple source files and project signing remain unchanged.

The Android implementation follows the Apple visual structure and theme. It is not a verified pixel-identical rendering: it uses OFL-licensed GFS Didot, original SVG icons and Android native controls in place of Apple's system fonts, SF Symbols and system UI. Pencil rendering and outline filtering use Android/browser implementations. See `android/README.md` for specific differences. Physical stylus/palm interaction, Android 10 runtime and broader accessibility/font-scale checks remain follow-up coverage.

## Privacy publication

The existing website repository was updated only at `drawthroughprivacy.html`, commit `ce4d5cacb77842ec571f55e9b09f2bca8b78f5c3`. Its deployment succeeded and https://oanarinaldi.com/drawthroughprivacy.html now covers Android, lessons, drawings, reflections and local-only data handling. Unrelated website working files were left untouched.

## Next Play steps

After confirmation of the required declarations: create the app, complete its listing and policy questionnaires, enable Play App Signing as prompted, upload the signed AAB, choose the available production/testing track and submit for review. Preserve the existing account's country availability choices where applicable. If Play requires testing or another owner action, record that exact requirement rather than claiming production submission.
