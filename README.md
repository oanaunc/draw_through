# Draw Through

A native iPhone and iPad drawing field school and reference studio. Requires iOS 17+.

- **Learn:** 20 original illustrated lessons, four chapters, search, bookmarks, and course progress.
- **Practice:** PencilKit finger/Apple Pencil drawing with pencil, ink, eraser, undo/redo, and Guide → Faint → Freehand modes.
- **My practice:** one saved drawing per lesson, optional reflections, completion, and sharing. Everything stays on-device unless shared.
- **Studio:** arrange reference photos, adjust layers, use outlines and a grid, and lock a composition for tracing on paper.

Open `DrawThrough.xcodeproj` in Xcode. `project.yml` is the XcodeGen source of truth; regenerate with `xcodegen generate` after changing targets or files. The existing bundle ID and signing team are preserved. Build 2 is prepared locally; no App Store upload is implied.

Run the `DrawThrough` scheme's tests on an iOS simulator. The unit tests cover persistence, completion, failed writes, corrupt files, and drawing coordinates across resize. UI tests exercise drawing, guidance, completion, relaunch, the journal, search, and studio access.

See [validation and screenshots](docs/Validation.md). Read [product research](docs/ProductResearch.md) and the [revised App Store submission draft](AppStoreSubmission.md). Existing numbered screenshot sets and the walkthrough video are historical: replace them with current screenshots before submitting this revision.
