# Draw Through — Android 1.0.0 (1)

Prepared on **23 October 2026**, Europe/Bucharest.

## Current release state

The Android app is implemented, tested, signed, pushed to `main` and **submitted to Google Play for production review**. On 23 October 2026 at approximately 22:37 Europe/Bucharest (19:37 UTC), Play confirmed **“11 changes sent for review”** and displayed **“Changes in review”**, including production **1.0.0 (1), Start full rollout**. Google's quick checks were still running at verification; the submission will proceed through those checks automatically. This is not approval or public availability.

The free English (United States) **Draw Through** entry uses package `com.oanarinaldi.drawthrough`, app ID `4976230497312384698`. All 178 offered country/region rows are targeted (177 named markets plus Rest of World). The existing managed-publishing setting is off. The user confirmed Google's Developer Program Policies / US export declarations and separately the IARC Terms of Use. IARC is completed: ESRB Everyone, PEGI 3, equivalent all-ages/3+ regional ratings. The intended audience declaration is 13 and older.

[Publishing overview](https://play.google.com/console/u/0/developers/8359156760975569195/app/4976230497312384698/publishing?hl=en) · [App dashboard](https://play.google.com/console/u/0/developers/8359156760975569195/app/4976230497312384698/app-dashboard?hl=en). Screenshot evidence: `validation/Play-Submitted-For-Review.png`; structured receipt: `SubmissionReceipt.json`.

Implementation commit: `82fcee00216ed7445199dabd313fc5528aefb9cf`. The exact locally verified signed AAB was uploaded successfully; Play recognized version code 1, version name 1.0.0, minimum API 29 and target API 36, and marked it “Ready to release.” Play App Signing and automatic protection were already active in the release form. No new signing agreement prompt appeared. The required advertising ID declaration was completed as **No** after quick checks identified it as missing; the issue cleared before submission.

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

## Remaining external review

Google's automated quick checks and review remain pending. Play stated that review is typically completed within seven days but may take longer. The console has accepted the review request; no further submission action was pending at verification. With managed publishing off, approved changes are intended to publish automatically. Monitor the publishing overview for any policy or app-quality findings. The in-app browser was left open to that page.
