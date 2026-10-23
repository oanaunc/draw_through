# Draw Through

A native iPhone and iPad drawing field school and reference studio. Requires iOS 17+.

- **Learn:** 100 complete workshops in 12 chapters, each with its own unique reference image, detailed demonstration, troubleshooting, independent assignment, search, bookmarks, and course progress.
- **References:** 100 offline AI-created images, subject filtering, zoom, monochrome and an observation grid. Open a related lesson or create a Studio composition from any reference.
- **Practice:** PencilKit drawing with pencil, ink, eraser, undo/redo, Guide → Faint → Freehand, an optional grid, and a personal photo reference saved with each lesson.
- **My practice:** one revisitable drawing per lesson, reflections, completion, and sharing. Data stays on-device unless shared.
- **Studio:** arrange personal reference photos in layers, adjust opacity, contrast and outlines, and lock a composition for tracing on paper.

Open `DrawThrough.xcodeproj` in Xcode. `project.yml` is the XcodeGen source of truth; regenerate with `xcodegen generate` after changing files. The existing bundle ID and signing team are retained; the expanded release is version 1.0.0, build 6.

Run the `DrawThrough` scheme's tests on an iOS simulator. Unit tests cover curriculum completeness, 100 distinct bundled images, full workshop content, personal-reference persistence, drawing persistence, failed writes, corrupt files, and resize coordinates. UI tests cover drawing and journal flows, onboarding, search, gallery tools, the gallery-to-lesson-to-Studio path, and long workshop reading.

See [validation](docs/Validation.md), [product research](docs/ProductResearch.md), [image provenance and prompts](docs/reference-art/README.md), and [submission materials](AppStoreSubmission.md).

## Android / Google Play

The Android edition lives in [`android/`](android/README.md). It carries the complete Apple curriculum and original artwork into an offline Android drawing app with native photo selection and image export. Build instructions, platform-specific rendering differences and signing details are documented there. Google Play listing materials, genuine device captures and validation evidence are in [`release/google-play/`](release/google-play/).
