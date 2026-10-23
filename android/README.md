# Draw Through for Android

An offline Android edition of the Apple app, package `com.oanarinaldi.drawthrough`, version **1.0.0 (1)**. Android 10+; compile/target API 36.

## Content and behavior

- All 100 lessons, 100 complete workshops, 12 chapters and 100 distinct original reference images are exported from the Swift source. Setup, demonstrations, troubleshooting, assignments, questions, exercises and transfer activities are included without abridgment.
- Learn, chapter expansion/filtering, search, saved lessons, progress and the next unfinished lesson.
- The complete reference gallery, subject filtering, monochrome, observation grid, pinch/double-tap zoom, lesson links and composition creation.
- A finger/stylus practice pad with canonical 720×540 strokes, pressure, Pencil/Ink/stroke eraser, undo/redo, Guide/Faint/Freehand, all 20 original construction diagrams, personal references, reflection, completion and image sharing. Completion requires saved marks.
- My practice, dated studies, drawings, reflections and reopening saved work.
- Studio compositions with photo layers, drag/resize/pinch/rotation, order, visibility, locks, layer names, opacity, brightness, contrast, color/monochrome/outline, backgrounds, grid, fit/reset, two-finger pan, trace lock with two-second unlock, screen-awake setting, save, duplication, favorites, deletion and PNG save/share.
- Three-page introduction, settings, tips, support and privacy.

The editorial interface is packaged locally in a restricted WebView, with Android-owned atomic JSON files, private image files, native single/multiple photo pickers, MediaStore export and FileProvider sharing. It has no Internet permission, account, server, analytics, advertising, purchases, or resource downloads. External privacy/support links open only on an explicit tap. Cloud backup and device transfer are excluded. Unreadable files are preserved and reported; failed saves do not award completion. A duplicated composition retains all layers and transformations.

## Visual parity and limits

Colors, artwork, paper treatment, hierarchy, card spacing and floating four-tab navigation follow `DrawThrough/Theme.swift` and the Apple screen implementations. `SubmissionArtifacts/Build6/Raw/` is the visual reference. Course and onboarding images are reused byte for byte.

The Apple app requests Apple's system Didot and system serif/SF Symbols. Android bundles **GFS Didot under the SIL Open Font License**, uses its available serif body font and original SVG outline icons; Apple system fonts/SF Symbols are not copied into Android. Native photo pickers, share sheets, keyboards, system bars, PencilKit pencil rendering and Core Image edge filtering have platform-specific equivalents. Consequently this is a faithful content/feature port, **not a verified pixel-identical Apple rendering**. The Android outline uses a local Sobel edge filter. Physical stylus pressure/palm behavior and Android 10 runtime remain hardware/runtime follow-up coverage.

## Build

On this Mac:

```sh
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export ANDROID_HOME="$HOME/Library/Android/sdk"
./android/gradlew -p android assembleDebug lintDebug
ANDROID_SERIAL=emulator-5560 ./android/gradlew -p android connectedDebugAndroidTest
python3 android/scripts/build-release.py
```

The Gradle wrapper is pinned to its SHA-256. Android Studio can open `android/`. On another computer configure your SDK path through `ANDROID_HOME` or an ignored `android/local.properties`.

The release script reads the private upload key from `~/.local/share/drawthrough/android-upload/signing.json`, outside Git. Override with `DRAWTHROUGH_SIGNING_CONFIG`. Fields are `keystore`, `storePassword`, `keyPassword`, `alias`. Securely back up that directory; do not replace a key after a Play upload. Credentials never appear in command arguments or app assets.

Outputs: `app/build/outputs/bundle/release/app-release.aab` and `app/build/outputs/apk/release/app-release.apk`. APK/AAB files, Gradle caches, SDK paths and keys are ignored.

## Refresh the Apple content

```sh
python3 android/scripts/sync-ios-content.py
```

Requires Python and Pillow. The exporter reads the 20 foundation lessons from Swift and the 80 extended lessons / 100 workshops from their canonical JSON resources. It asserts sequential IDs, chapter coverage, full reading content and distinct image hashes. It also copies all three onboarding images and builds the launcher icon from the existing Apple asset.

Device tests cover course completeness and decodable unique artwork, actual touch drawing, undo/redo, reflections/completion, Activity recreation, gallery observation, composition persistence/duplication, corrupt-file preservation, failed storage and native photo import / PNG export. Test captures contain generated fixtures only. See `../release/google-play/` for reviewable media and release status; building alone does not imply Play submission or approval.
