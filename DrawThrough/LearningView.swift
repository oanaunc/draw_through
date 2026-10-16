import SwiftUI

struct StudioRootView: View {
    var body: some View {
        TabView {
            LearnView().tabItem { Label("Learn", systemImage: "book.closed") }
            ReferenceLibraryView().tabItem { Label("References", systemImage: "photo.on.rectangle.angled") }
            HomeView().tabItem { Label("Studio", systemImage: "square.3.layers.3d") }
            StudyJournalView().tabItem { Label("My practice", systemImage: "pencil.and.list.clipboard") }
        }
        .tint(DTTheme.ink)
    }
}

struct LearnView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject private var learning: LearningStore
    @State private var search = ""
    @FocusState private var searching: Bool
    @State private var bookmarkedOnly = false
    @State private var showSettings = false
    @State private var selectedChapter: Int?
    @State private var expandedChapters: Set<Int> = [0]

    private var matching: [DrawingLesson] {
        DrawingLesson.all.filter { lesson in
            (selectedChapter == nil || selectedChapter == lesson.chapter) &&
            (!bookmarkedOnly || learning.progress.bookmarks.contains(lesson.id)) &&
            (search.isEmpty || "\(lesson.title) \(lesson.subtitle) \(lesson.chapterTitle)".localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 25) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("DRAW THROUGH · FIELD SCHOOL").font(DTTheme.smallCaps).tracking(1.8).foregroundStyle(DTTheme.clay)
                                Text("Learn to look.\nMake your mark.").font(DTTheme.display(36)).fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                            Button { showSettings = true } label: { Image(systemName: "gearshape").frame(width: 44, height: 44).background(.white.opacity(0.45), in: Circle()) }.accessibilityLabel("Settings")
                        }
                        Text("100 complete lessons. 100 unique references. A practice that becomes your own.")
                            .font(.system(.body, design: .serif)).foregroundStyle(DTTheme.clay)
                        featuredLesson
                        HStack {
                            Text("THE DRAWING PATH").font(DTTheme.smallCaps).tracking(1.5)
                            Spacer()
                            Text("\(learning.completedCount) / \(DrawingLesson.count) studied").font(.subheadline).foregroundStyle(DTTheme.clay)
                        }
                        ProgressView(value: Double(learning.completedCount), total: Double(DrawingLesson.count)).tint(DTTheme.clay).accessibilityLabel("Course progress")
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundStyle(DTTheme.clay)
                            TextField("Find a skill or lesson", text: $search)
                                .focused($searching).submitLabel(.search).onSubmit { searching = false }
                                .accessibilityIdentifier("lessonSearch")
                            if !search.isEmpty { Button { search = "" } label: { Image(systemName: "xmark.circle.fill") }.accessibilityLabel("Clear search") }
                        }.padding(14).background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 14))
                        HStack {
                            Menu {
                                Button("All chapters") { selectedChapter = nil }
                                ForEach(DrawingLesson.chapters.indices, id: \.self) { chapter in Button(DrawingLesson.chapters[chapter]) { selectedChapter = chapter } }
                            } label: { Label(selectedChapter.map { "Chapter \($0 + 1)" } ?? "All chapters", systemImage: "line.3.horizontal.decrease") }
                            Spacer()
                            Toggle(isOn: $bookmarkedOnly) { Label("Saved", systemImage: "bookmark") }.toggleStyle(.button).accessibilityIdentifier("savedLessonsFilter")
                        }.font(.subheadline)
                        if matching.isEmpty {
                            ContentUnavailableView("No lessons found", systemImage: "book.closed", description: Text("Try another search or turn off the Saved filter."))
                        }
                        ForEach(DrawingLesson.chapters.indices, id: \.self) { chapter in
                            let lessons = matching.filter { $0.chapter == chapter }
                            if !lessons.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    Button {
                                        if expandedChapters.contains(chapter) { expandedChapters.remove(chapter) } else { expandedChapters.insert(chapter) }
                                    } label: {
                                        HStack(spacing: 14) {
                                            ReferenceArtwork(reference: lessons[0].reference).frame(width: 86, height: 76).clipShape(RoundedRectangle(cornerRadius: 12)).accessibilityHidden(true)
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text("CHAPTER \(chapter + 1) · \(lessons.count) LESSONS").font(.caption2.weight(.medium)).tracking(0.8).foregroundStyle(DTTheme.clay)
                                                Text(DrawingLesson.chapters[chapter]).font(DTTheme.title(25))
                                                Text(DrawingLesson.chapterNotes[chapter]).font(.caption).foregroundStyle(DTTheme.clay)
                                            }
                                            Spacer(minLength: 0)
                                            Image(systemName: expandedChapters.contains(chapter) ? "chevron.up" : "chevron.down").font(.caption)
                                        }.padding(12).vellumSurface(radius: 16)
                                    }.buttonStyle(.plain).accessibilityLabel("Chapter \(chapter + 1): \(DrawingLesson.chapters[chapter])")
                                    if expandedChapters.contains(chapter) || selectedChapter != nil || !search.isEmpty || bookmarkedOnly {
                                        ForEach(lessons) { lesson in NavigationLink(value: lesson) { LessonRow(lesson: lesson) }.buttonStyle(.plain) }
                                    }
                                }
                            }
                        }
                        Text("Read → draw with a guide → fade it → try on your own.")
                            .font(.system(.footnote, design: .serif)).italic().foregroundStyle(DTTheme.clay).padding(.vertical, 12)
                    }.padding(22).frame(maxWidth: 900).frame(maxWidth: .infinity)
                }
            }
            .foregroundStyle(DTTheme.ink)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { searching = false } } }
            .navigationDestination(for: DrawingLesson.self) { LessonDetailView(lesson: $0) }
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    private var featuredLesson: some View {
        NavigationLink(value: learning.nextLesson) {
            VStack(alignment: .leading, spacing: 12) {
                HStack { Text(learning.completedCount == DrawingLesson.count ? "RETURN TO THE BEGINNING" : "YOUR NEXT SMALL STEP").font(DTTheme.smallCaps).tracking(1.5); Spacer(); Image(systemName: "arrow.up.right") }
                if sizeClass == .regular {
                    HStack(spacing: 28) {
                        ReferenceArtwork(reference: learning.nextLesson.reference)
                            .frame(width: 280).clipShape(RoundedRectangle(cornerRadius: 12)).background(DTTheme.vellum, in: RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 18) {
                            Text(learning.nextLesson.title).font(DTTheme.title(34))
                            Text(learning.nextLesson.subtitle).font(.system(.title3, design: .serif)).foregroundStyle(DTTheme.clay)
                            featuredFooter
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    ReferenceArtwork(reference: learning.nextLesson.reference).frame(maxHeight: 220).background(DTTheme.vellum, in: RoundedRectangle(cornerRadius: 12)).clipped()
                    Text(learning.nextLesson.title).font(DTTheme.title(30))
                    featuredFooter
                }
            }.padding(19).vellumSurface(radius: 22)
        }.buttonStyle(.plain)
    }
    private var featuredFooter: some View {
        HStack {
            Text("Lesson \(learning.nextLesson.number) · \(learning.nextLesson.minutes) min").foregroundStyle(DTTheme.clay)
            Spacer()
            Text("Begin study").fontWeight(.semibold)
            Image(systemName: "arrow.right")
        }.font(.subheadline)
    }

}

struct LessonRow: View {
    @EnvironmentObject private var learning: LearningStore
    let lesson: DrawingLesson
    var body: some View {
        HStack(spacing: 14) {
            ReferenceArtwork(reference: lesson.reference).frame(width: 85, height: 70).clipShape(RoundedRectangle(cornerRadius: 10)).background(DTTheme.vellum, in: RoundedRectangle(cornerRadius: 10)).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(lesson.number)  ·  \(lesson.minutes) MIN").font(.caption.weight(.medium)).tracking(0.8).foregroundStyle(DTTheme.clay)
                Text(lesson.title).font(.system(.headline, design: .serif))
                Text(lesson.subtitle).font(.caption).foregroundStyle(DTTheme.clay)
            }
            Spacer(minLength: 0)
            Image(systemName: learning.progress.studies[lesson.id]?.completedAt != nil ? "checkmark.circle.fill" : "chevron.right")
                .foregroundStyle(DTTheme.clay).accessibilityLabel(learning.progress.studies[lesson.id]?.completedAt != nil ? "Completed" : "Open lesson")
        }.padding(12).vellumSurface(radius: 16).contentShape(Rectangle())
    }
}

struct LessonDetailView: View {
    @EnvironmentObject private var learning: LearningStore
    let lesson: DrawingLesson
    @State private var showPractice = false
    @State private var showReference = false
    var body: some View {
        ZStack {
            PaperBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("CHAPTER \(lesson.chapter + 1) · LESSON \(lesson.number) · \(lesson.minutes) MIN").font(DTTheme.smallCaps).tracking(1.5).foregroundStyle(DTTheme.clay)
                    Text(lesson.title).font(DTTheme.display(42)).fixedSize(horizontal: false, vertical: true)
                    Text(lesson.subtitle).font(.system(.title3, design: .serif)).foregroundStyle(DTTheme.clay)
                    Button { showReference = true } label: {
                        ReferenceArtwork(reference: lesson.reference).clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(alignment: .bottomTrailing) { Label("Study the reference", systemImage: "arrow.up.left.and.arrow.down.right").font(.caption.weight(.semibold)).padding(10).background(.regularMaterial, in: Capsule()).padding(12) }
                    }.buttonStyle(.plain)
                    Text("\(lesson.reference.title) · AI-created reference").font(.caption).foregroundStyle(DTTheme.clay)
                    if lesson.id <= 20 {
                        DisclosureGroup("The construction study") { LessonIllustration(lessonID: lesson.id).background(DTTheme.vellum, in: RoundedRectangle(cornerRadius: 16)) }
                            .font(.system(.headline, design: .serif))
                    }
                    lessonText("The idea", lesson.idea)
                    lessonText("Look closely", lesson.observation)
                    if let workshop = lesson.workshop {
                        lessonText("Before you draw", workshop.setup)
                        lessonText("Work through the reference", workshop.demonstration)
                    }
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Try it, three ways").font(DTTheme.title(28))
                        ForEach(Array(lesson.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 14) {
                                Text("\(index + 1)").font(DTTheme.title(25)).foregroundStyle(DTTheme.sepia).frame(width: 24)
                                Text(step).font(.system(.body, design: .serif)).lineSpacing(5).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }.padding(20).vellumSurface()
                    if let workshop = lesson.workshop {
                        lessonText("Common mistakes & fixes", workshop.mistakes)
                        lessonText("Your independent assignment", workshop.challenge)
                    }
                    lessonText("Ask yourself", lesson.check)
                    lessonText("Take it off the screen", lesson.transfer)
                    if let next = DrawingLesson.all.first(where: { $0.id == lesson.id + 1 }) {
                        NavigationLink(value: next) { Label("Next: \(next.title)", systemImage: "arrow.right").font(.subheadline).padding(.vertical, 10) }
                    }
                }.padding(24).frame(maxWidth: 760).frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(DTTheme.ink)
        .navigationTitle("Lesson \(lesson.number)").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { learning.toggleBookmark(lesson.id) } label: { Image(systemName: learning.progress.bookmarks.contains(lesson.id) ? "bookmark.fill" : "bookmark") }
                    .accessibilityLabel(learning.progress.bookmarks.contains(lesson.id) ? "Unsave lesson" : "Save lesson")
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button { showPractice = true } label: { Label(learning.progress.studies[lesson.id] == nil ? "Open practice pad" : "Continue practice", systemImage: "pencil.tip") }
                .buttonStyle(InkButtonStyle()).padding(.horizontal, 22).padding(.vertical, 12).background(.regularMaterial)
        }
        .fullScreenCover(isPresented: $showPractice) { LessonPracticeView(lesson: lesson) }
        .fullScreenCover(isPresented: $showReference) { ReferenceViewer(reference: lesson.reference) }
    }
    private func lessonText(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(DTTheme.title(28))
            Text(text).font(.system(.body, design: .serif)).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct StudyJournalView: View {
    @EnvironmentObject private var learning: LearningStore
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("A RECORD OF LOOKING").font(DTTheme.smallCaps).tracking(2).foregroundStyle(DTTheme.clay)
                        Text("My practice").font(DTTheme.display(44))
                        Text("Every study is a step forward. Return to a drawing, notice what changed, and try again.").font(.system(.body, design: .serif)).foregroundStyle(DTTheme.clay).lineSpacing(4)
                        HStack(spacing: 28) {
                            metric("\(learning.completedCount)", "lessons studied")
                            metric("\(learning.progress.studies.count)", "saved studies")
                            metric("\(learning.progress.bookmarks.count)", "lessons saved")
                        }.padding(20).frame(maxWidth: .infinity).vellumSurface()
                        if learning.recentLessons.isEmpty {
                            ContentUnavailableView("Your first marks belong here", systemImage: "pencil.and.outline", description: Text("Open a lesson in Learn and make a drawing on its practice pad. Your studies and reflections will stay here on this device."))
                        }
                        ForEach(learning.recentLessons) { lesson in
                            NavigationLink(value: lesson) {
                                VStack(alignment: .leading, spacing: 12) {
                                    LessonRow(lesson: lesson)
                                    if let study = learning.progress.studies[lesson.id] {
                                        Text(study.updatedAt, format: .dateTime.month(.abbreviated).day().year()).font(.caption).foregroundStyle(DTTheme.clay)
                                        if let drawing = try? learning.drawing(for: lesson.id), !drawing.strokes.isEmpty {
                                            Image(uiImage: drawing.image(from: CGRect(x: 0, y: 0, width: 720, height: 540), scale: 1))
                                                .resizable().aspectRatio(4 / 3, contentMode: .fit).background(DTTheme.vellum, in: RoundedRectangle(cornerRadius: 12))
                                                .accessibilityLabel("Your saved drawing for \(lesson.title)")
                                        }
                                        if !study.reflection.isEmpty { Text(study.reflection).font(.system(.body, design: .serif)).lineLimit(4).foregroundStyle(DTTheme.clay) }
                                        Text(study.completedAt == nil ? "In progress · tap to continue" : "Studied · tap to revisit").font(.caption.weight(.medium))
                                    }
                                }.padding(14).vellumSurface()
                            }.buttonStyle(.plain)
                        }
                        Text("Saved on this device. Use Share in the practice pad to keep a copy of a drawing.").font(.footnote).foregroundStyle(DTTheme.clay)
                    }.padding(22).frame(maxWidth: 850).frame(maxWidth: .infinity)
                }
            }
            .foregroundStyle(DTTheme.ink)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: DrawingLesson.self) { LessonDetailView(lesson: $0) }
        }
    }
    private func metric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) { Text(value).font(DTTheme.title(34)); Text(label).font(.caption).foregroundStyle(DTTheme.clay) }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
