# Draw Through: product direction and App Review response

Research date: 16 October 2026. This is a product assessment, not a guarantee of App Store acceptance.

## What the rejection establishes

Apple's message for submission `0722215f-36b6-4803-86e8-72e6fd0e61f6` cites **4.3(a)** and similarity in the binary, metadata, and/or concept to other submissions. It does not identify a comparison app or establish that simultaneous submissions were the cause. We cannot audit similarity across the developer's other apps from this repository alone.

Apple's [current guidelines](https://developer.apple.com/app-store/review/guidelines/#4.3) discourage multiple bundle IDs for the same app. Section 4.2 asks for lasting utility and an app-like experience; reading pages alone do not establish that. Apple's [review guidance](https://developer.apple.com/app-store/review/) recommends explaining misunderstood functionality and provides an appeal route.

Recommendation: improve the existing app and submit a new build on the existing record. Do not use a new bundle ID or superficial rename as a way around this rejection. Ask App Review which aspects remain similar if a revised, well-documented submission is rejected. Approval remains Apple's decision.

## What the existing app does well

The repository contains a native SwiftUI reference-composition tool with image layers, transformations, outline and monochrome filters, opacity, a tracing lock, local project storage, and sharing. Its warm paper and serif typography form a coherent visual direction. These are useful foundations.

Its initial screen was mostly an empty project grid. The entire learning offering was five short tracing tips. There was no in-app freehand drawing, structured curriculum, practice history, or bridge from tracing to independent observation. This assessment concerns the checked-in app, not Apple's private comparison process.

## Comparable products, from their own materials

| Product | Established emphasis | Implication for Draw Through |
| --- | --- | --- |
| [Sketch a Day](https://sketchaday.app/) | Daily prompts, artist tutorials, community, progress rewards | A reason to return matters. A prompt feed alone would not differentiate this app. |
| [Sketchar](https://sketchar.io/) | AR tracing, step-by-step lessons, courses, built-in templates | More tracing templates alone would compete on quantity. Focus on transferring observation skills instead. |
| [Sketchbook](https://help.sketchbook.com/docs/tools-overview) | A broad drawing toolkit including guides, transforms, shapes, perspective, and time-lapse | Do not try to recreate a professional painting suite in this revision. Keep the practice tools focused. |

The product direction below is our inference from these feature descriptions, not a claim that competitors lack any particular feature.

## Recommended promise

**Learn to look, practice with less help, and make a drawing of your own.**

Use the sequence **Read → Guide → Faint → Freehand → Reflect**. Preserve the light table as the place for the user's own reference compositions. Make learning the first-run experience so new users and reviewers can immediately explore useful bundled content without photo permissions, downloads, or account creation.

## Implemented in this revision

- Twenty original lessons in four chapters: line; observation; form and light; personal studies.
- Each lesson includes a core idea, an explanation of its illustration, three exercise steps, a self-review question, and an off-screen exercise.
- Twenty original instructional illustrations drawn natively with SwiftUI paths. No scraped textbook pages, external lesson dependencies, or generated raster assets are required.
- A native PencilKit practice pad with finger and Apple Pencil input, pencil/ink/vector eraser, undo/redo, and three levels of reference guidance.
- Local drawing autosave, explicit completion after making marks, optional reflections, lesson bookmarks, course progress, and a journal with actual saved drawing previews.
- Saved drawings use a canonical coordinate system so orientation and window size changes preserve alignment with the guide.
- Clear drawing asks for confirmation. Saving errors are shown; unreadable drawings are preserved rather than silently replaced.
- Three main destinations: Learn, Studio, and My practice. Updated onboarding explains all three.
- The existing light table remains available, and its default canvas preference is now honored.
- Removed unused promotional demo screens, including nonfunctional export options, from the executable source. Removed settings switches that did not affect behavior.
- Added an in-app privacy-policy link and support contact, plus the UserDefaults required-reason privacy manifest. See [Apple’s required-reason API documentation](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype).
- Original bundle ID retained; build number increased to 2, with the existing marketing version and signing team preserved.

This is a substantial functional revision, but it does not prove that Apple's similarity concern has been resolved across all other submissions. Be specific and truthful when describing it.

## Design choices

Retain the editorial identity rather than replacing it with an unrelated template. Make type and section hierarchy clearer; show an illustrated next lesson on first launch; use an explicit course path and distinguish incomplete from completed studies. Lesson pages use readable text measures and illustrations that also serve as practice guides. The UI adapts to phone and tablet widths.

Working descriptor: **Draw Through · Field School**. This is in-app language, not a reserved or trademark-cleared new App Store name. A replacement brand should be checked before changing the public listing. The current App Store name remains Draw Through.

## After this build

1. Review the lesson text and examples with a drawing teacher and observe a few beginner sessions. No expert endorsement or measured learning outcome is claimed.
2. Test Apple Pencil pressure and palm interaction on a physical iPad; simulator finger tests cannot establish hardware behavior.
3. Capture current, real product screenshots and replace the historical promotional sets and walkthrough video. Do not reuse screenshots showing demo-only controls.
4. Audit the developer's other submitted apps against this product's code, artwork, metadata, and purpose. That evidence is unavailable in this workspace.
5. Submit the revised build with the concrete reviewer walkthrough in `AppStoreSubmission.md`. If necessary, request clarification or appeal with evidence instead of assuming the rejection's cause.

Potential later features: multiple dated attempts per lesson with side-by-side comparison, imported photos for lesson-specific observation studies, and accessible audio descriptions of diagrams. These are not advertised as present. The current journal holds one revisitable drawing per lesson; sharing exports a copy, and clearing or redrawing updates that lesson's saved drawing.
