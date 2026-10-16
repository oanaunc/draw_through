import SwiftUI

struct StudyReference: Identifiable, Hashable {
    let id: String
    let title: String
    let subject: String
    let focus: String
    let description: String
    var imageName: String { "Lesson-\(id).jpg" }
    var lessons: [DrawingLesson] { DrawingLesson.all.filter { $0.id == Int(id) } }

    static let all: [StudyReference] = {
        let references = DrawingLesson.all.map { lesson in
            StudyReference(id: String(format: "%03d", lesson.id), title: lesson.title,
                           subject: lesson.chapterTitle, focus: DrawingLesson.chapterNotes[lesson.chapter],
                           description: lesson.observation)
        }
        let featured = [31, 21, 26, 41, 51, 71, 81, 91]
        return featured.compactMap { number in references.first { Int($0.id) == number } } + references.filter { !featured.contains(Int($0.id) ?? 0) }
    }()
    static func forLesson(_ id: Int) -> StudyReference {
        all.first { Int($0.id) == id } ?? all[0]
    }
}

struct ReferenceArtwork: View {
    let reference: StudyReference
    var body: some View {
        Group {
            if let image = UIImage(named: reference.imageName) {
                Image(uiImage: image).resizable().aspectRatio(4 / 3, contentMode: .fit)
            } else {
                Rectangle().fill(DTTheme.parchment).aspectRatio(4 / 3, contentMode: .fit)
                    .overlay { Image(systemName: "photo").foregroundStyle(DTTheme.clay) }
            }
        }.accessibilityLabel(reference.title)
    }
}

struct ReferenceLibraryView: View {
    @State private var subject = "All subjects"
    private let subjects = ["All subjects"] + DrawingLesson.chapters
    private var matching: [StudyReference] { StudyReference.all.filter { subject == "All subjects" || $0.subject == subject } }
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("THE REFERENCE COLLECTION").font(DTTheme.smallCaps).tracking(1.8).foregroundStyle(DTTheme.clay)
                        Text("Something worth\nlooking at.").font(DTTheme.display(40))
                        Text("100 unique references. A new image for every lesson, with space to look closer and make it your own.").font(.system(.body, design: .serif)).foregroundStyle(DTTheme.clay)
                        Menu {
                            ForEach(subjects, id: \.self) { value in Button(value) { subject = value } }
                        } label: { Label(subject, systemImage: "line.3.horizontal.decrease").font(.subheadline).padding(12).vellumSurface(radius: 12) }
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 16, alignment: .topLeading)], spacing: 22) {
                            ForEach(matching) { reference in
                                NavigationLink(value: reference) {
                                    VStack(alignment: .leading, spacing: 9) {
                                        ReferenceArtwork(reference: reference).clipShape(RoundedRectangle(cornerRadius: 13))
                                        Text(reference.subject.uppercased()).font(.caption2.weight(.medium)).tracking(1).foregroundStyle(DTTheme.clay)
                                        Text(reference.title).font(.system(.headline, design: .serif)).fixedSize(horizontal: false, vertical: true)
                                        Text("Lesson \(reference.id)").font(.caption).foregroundStyle(DTTheme.clay)
                                    }
                                }.buttonStyle(.plain).accessibilityIdentifier("reference-\(reference.id)")
                            }
                        }
                        Text("Original AI-created reference images, curated for observation practice. They depict imagined subjects; use life and your own photos to check anatomy and physical detail. All images are included offline.").font(.footnote).foregroundStyle(DTTheme.clay).lineSpacing(4)
                    }.padding(22).frame(maxWidth: 1000).frame(maxWidth: .infinity)
                }
            }.foregroundStyle(DTTheme.ink)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: StudyReference.self) { ReferenceDetailView(reference: $0) }
            .navigationDestination(for: DrawingLesson.self) { LessonDetailView(lesson: $0) }
        }
    }
}

struct ReferenceDetailView: View {
    @EnvironmentObject private var store: ProjectStore
    let reference: StudyReference
    @State private var showViewer = false
    @State private var project: ProjectSummary?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(reference.subject.uppercased()).font(DTTheme.smallCaps).tracking(1.6).foregroundStyle(DTTheme.clay)
                Text(reference.title).font(DTTheme.display(38))
                Button { showViewer = true } label: { ReferenceArtwork(reference: reference).clipShape(RoundedRectangle(cornerRadius: 18)).overlay(alignment: .bottomTrailing) { Label("Look closer", systemImage: "arrow.up.left.and.arrow.down.right").font(.caption.weight(.semibold)).padding(10).background(.regularMaterial, in: Capsule()).padding(12) } }.buttonStyle(.plain)
                Text(reference.description).font(.system(.body, design: .serif)).lineSpacing(5)
                Text(reference.focus).font(.subheadline).foregroundStyle(DTTheme.clay)
                Button {
                    project = store.create(reference: reference)
                } label: { Label("Arrange in the light table", systemImage: "square.3.layers.3d") }.buttonStyle(InkButtonStyle())
                Text("Make this reference part of a composition, or add your own photos in Studio.").font(.footnote).foregroundStyle(DTTheme.clay)
                Text("Study this subject").font(DTTheme.title(29))
                ForEach(reference.lessons) { lesson in NavigationLink(value: lesson) { LessonRow(lesson: lesson) }.buttonStyle(.plain) }
                Text("AI-created reference · included offline").font(.caption).foregroundStyle(DTTheme.clay)
            }.padding(22).frame(maxWidth: 760).frame(maxWidth: .infinity)
        }.background { PaperBackground() }.foregroundStyle(DTTheme.ink)
        .navigationTitle("Reference").navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showViewer) { ReferenceViewer(reference: reference) }
        .navigationDestination(item: $project) { CanvasView(project: $0) }
    }
}

struct ReferenceViewer: View {
    @Environment(\.dismiss) private var dismiss
    let reference: StudyReference
    @State private var monochrome = false
    @State private var grid = false
    @State private var scale: CGFloat = 1
    @GestureState private var gestureScale: CGFloat = 1
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Spacer(minLength: 0)
                ReferenceArtwork(reference: reference).saturation(monochrome ? 0 : 1)
                    .overlay { if grid { ObservationGrid().stroke(.white.opacity(0.7), lineWidth: 1).allowsHitTesting(false) } }
                    .scaleEffect(min(max(scale * gestureScale, 1), 3))
                    .gesture(MagnifyGesture().updating($gestureScale) { value, state, _ in state = value.magnification }.onEnded { scale = min(max(scale * $0.magnification, 1), 3) })
                    .onTapGesture(count: 2) { scale = scale == 1 ? 2 : 1 }
                    .frame(maxWidth: .infinity).clipped()
                Spacer(minLength: 0)
                Text(reference.focus).font(.system(.subheadline, design: .serif)).foregroundStyle(DTTheme.clay)
                HStack {
                    Toggle("Monochrome", isOn: $monochrome).toggleStyle(.button).accessibilityIdentifier("referenceMonochrome")
                    Toggle("Grid", isOn: $grid).toggleStyle(.button).accessibilityIdentifier("referenceGrid")
                    Button("Reset zoom") { scale = 1 }
                }.font(.subheadline).padding(.bottom, 12)
                Text("Pinch to zoom · double-tap to reset or enlarge").font(.caption).foregroundStyle(DTTheme.clay)
            }.padding(18).background(DTTheme.vellum)
            .navigationTitle(reference.title).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() } } }
        }.tint(DTTheme.ink)
    }
}

struct ObservationGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        for i in 1..<4 {
            let x = rect.minX + rect.width * CGFloat(i) / 4
            let y = rect.minY + rect.height * CGFloat(i) / 4
            p.move(to: CGPoint(x: x, y: rect.minY)); p.addLine(to: CGPoint(x: x, y: rect.maxY))
            p.move(to: CGPoint(x: rect.minX, y: y)); p.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return p
    }
}
