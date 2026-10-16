import SwiftUI
import PencilKit

/// Keeps artwork aligned with the illustration when the device or window changes size.
final class StudyCanvas: PKCanvasView {
    private var drawingWidth: CGFloat = 720
    var isResizing = false
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isResizing, bounds.width > 0, abs(bounds.width - drawingWidth) > 0.1 else { return }
        let ratio = bounds.width / drawingWidth
        drawingWidth = bounds.width
        isResizing = true
        drawing = drawing.transformed(using: CGAffineTransform(scaleX: ratio, y: ratio))
        isResizing = false
    }
    var canonicalDrawing: PKDrawing {
        drawing.transformed(using: CGAffineTransform(scaleX: 720 / drawingWidth, y: 720 / drawingWidth))
    }
    func load(_ value: PKDrawing) {
        // Resolve the viewport before assigning: PencilKit can lay out during its setter.
        layoutIfNeeded()
        isResizing = true
        drawing = value.transformed(using: CGAffineTransform(scaleX: drawingWidth / 720, y: drawingWidth / 720))
        isResizing = false
    }
}

@MainActor final class StudyPad: ObservableObject {
    let canvas = StudyCanvas()
    @Published var revision = 0
    @Published var strokeCount = 0
    @Published var canUndo = false
    @Published var canRedo = false
    func changed() {
        strokeCount = canvas.drawing.strokes.count
        canUndo = canvas.undoManager?.canUndo ?? false
        canRedo = canvas.undoManager?.canRedo ?? false
        revision += 1
    }
}

private struct PencilPracticePad: UIViewRepresentable {
    @ObservedObject var pad: StudyPad
    let ink: Bool
    let eraser: Bool
    func makeUIView(context: Context) -> StudyCanvas {
        let view = pad.canvas
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        view.isOpaque = false
        view.drawingPolicy = .anyInput
        view.isScrollEnabled = false
        view.accessibilityIdentifier = "practiceCanvas"
        view.accessibilityLabel = "Drawing practice pad. Draw with a finger or Apple Pencil."
        return view
    }
    func updateUIView(_ view: StudyCanvas, context: Context) {
        view.tool = eraser ? PKEraserTool(.vector) : PKInkingTool(ink ? .pen : .pencil, color: UIColor(DTTheme.ink), width: ink ? 3 : 5)
    }
    func makeCoordinator() -> Coordinator { Coordinator(pad) }
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        let pad: StudyPad
        init(_ pad: StudyPad) { self.pad = pad }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !pad.canvas.isResizing else { return }
            pad.changed()
        }
    }
}

struct LessonPracticeView: View {
    @EnvironmentObject private var learning: LearningStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    let lesson: DrawingLesson
    @StateObject private var pad = StudyPad()
    @State private var guideMode = 0
    @State private var tool = 0
    @State private var reflection = ""
    @State private var loaded = false
    @State private var dirty = false
    @State private var showClear = false
    @State private var error: String?
    @State private var saved = false
    @State private var saveTask: Task<Void, Never>?
    @FocusState private var writingReflection: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(lesson.title).font(DTTheme.title(30))
                        Text(lesson.steps[min(guideMode, 2)]).font(.system(.subheadline, design: .serif)).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                        Picker("Reference guidance", selection: $guideMode) {
                            Text("Guide").tag(0); Text("Faint").tag(1); Text("Freehand").tag(2)
                        }.pickerStyle(.segmented)
                        ZStack {
                            DTTheme.vellum
                            LessonIllustration(lessonID: lesson.id).opacity(guideMode == 0 ? 0.65 : guideMode == 1 ? 0.16 : 0).allowsHitTesting(false).accessibilityHidden(true)
                            PencilPracticePad(pad: pad, ink: tool == 1, eraser: tool == 2)
                                .disabled(!loaded)
                        }
                        .aspectRatio(4 / 3, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay { RoundedRectangle(cornerRadius: 14).stroke(DTTheme.line, lineWidth: 1) }
                        .accessibilityIdentifier("practiceSurface")
                        HStack {
                            Picker("Drawing tool", selection: $tool) {
                                Text("Pencil").tag(0); Text("Ink").tag(1); Text("Eraser").tag(2)
                            }.pickerStyle(.segmented)
                            Button { pad.canvas.undoManager?.undo(); pad.changed() } label: { Image(systemName: "arrow.uturn.backward").frame(width: 38, height: 44) }.disabled(!pad.canUndo).foregroundStyle(pad.canUndo ? DTTheme.ink : DTTheme.clay.opacity(0.3)).accessibilityLabel("Undo stroke")
                            Button { pad.canvas.undoManager?.redo(); pad.changed() } label: { Image(systemName: "arrow.uturn.forward").frame(width: 38, height: 44) }.disabled(!pad.canRedo).foregroundStyle(pad.canRedo ? DTTheme.ink : DTTheme.clay.opacity(0.3)).accessibilityLabel("Redo stroke")
                        }
                        HStack {
                            Text(saved && !dirty ? "Saved on this device" : "Your drawing saves as you work").font(.caption).foregroundStyle(DTTheme.clay).accessibilityIdentifier("saveStatus")
                            Spacer()
                            Button("Clear", role: .destructive) { showClear = true }.font(.subheadline).disabled(pad.strokeCount == 0)
                        }
                        Text("Look back at your study").font(DTTheme.title(25))
                        Text(lesson.check).font(.system(.body, design: .serif)).foregroundStyle(DTTheme.clay)
                        TextField("One thing I noticed. One thing to try next…", text: $reflection, axis: .vertical)
                            .lineLimit(3...6).padding(14).background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                            .focused($writingReflection).accessibilityIdentifier("studyReflection")
                        Button {
                            writingReflection = false
                            if save(complete: true) { dismiss() }
                        } label: { Label("Complete study", systemImage: "checkmark.circle") }
                            .buttonStyle(InkButtonStyle()).disabled(!loaded || pad.strokeCount == 0)
                        Text("Completion is your own reflection on the exercise, not an automatic skill assessment. You can return and practice again anytime.").font(.footnote).foregroundStyle(DTTheme.clay)
                    }.padding(20).frame(maxWidth: 850).frame(maxWidth: .infinity)
                }.scrollDismissesKeyboard(.interactively)
            }
            .foregroundStyle(DTTheme.ink)
            .navigationTitle("Practice · \(lesson.number)").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Close") { if !loaded || !dirty || save() { dismiss() } } }
                ToolbarItem(placement: .topBarTrailing) {
                    if pad.strokeCount > 0 {
                        ShareLink(item: Image(uiImage: exportImage), preview: SharePreview(lesson.title, image: Image(uiImage: exportImage))) {
                            Image(systemName: "square.and.arrow.up")
                        }.accessibilityLabel("Share study")
                    }
                }
                ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { writingReflection = false } }
            }
            .confirmationDialog("Clear this drawing?", isPresented: $showClear, titleVisibility: .visible) {
                Button("Clear drawing", role: .destructive) { pad.canvas.drawing = PKDrawing(); pad.changed() }
                Button("Cancel", role: .cancel) { }
            } message: { Text("This clears the marks in this lesson's saved study. Your reflection stays.") }
            .alert("Your study needs attention", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("OK", role: .cancel) { error = nil }
            } message: { Text(error ?? "") }
            .onAppear(perform: load)
            .onChange(of: pad.revision) { _, _ in scheduleSave() }
            .onChange(of: reflection) { _, _ in scheduleSave() }
            .onChange(of: scenePhase) { _, phase in if phase != .active && dirty { _ = save() } }
            .onDisappear { saveTask?.cancel(); if dirty { _ = save() } }
        }
    }

    private var exportImage: UIImage {
        let image = pad.canvas.canonicalDrawing.image(from: CGRect(x: 0, y: 0, width: 720, height: 540), scale: 2)
        let format = UIGraphicsImageRendererFormat(); format.scale = 2; format.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: 720, height: 540), format: format).image { _ in
            UIColor(DTTheme.vellum).setFill(); UIRectFill(CGRect(x: 0, y: 0, width: 720, height: 540))
            image.draw(in: CGRect(x: 0, y: 0, width: 720, height: 540))
        }
    }
    private func load() {
        guard !loaded else { return }
        do {
            let drawing = try learning.drawing(for: lesson.id)
            pad.canvas.load(drawing)
            pad.strokeCount = drawing.strokes.count
            reflection = learning.progress.studies[lesson.id]?.reflection ?? ""
            saved = learning.progress.studies[lesson.id] != nil
            loaded = true
        } catch { self.error = "The saved drawing could not be opened. It has been preserved. Close the pad and try again. \(error.localizedDescription)" }
    }
    private func scheduleSave() {
        guard loaded else { return }
        dirty = true; saved = false
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(650))
            guard !Task.isCancelled else { return }
            _ = save()
        }
    }
    @discardableResult private func save(complete: Bool = false) -> Bool {
        guard loaded else { return false }
        saveTask?.cancel()
        do {
            try learning.save(pad.canvas.canonicalDrawing, lessonID: lesson.id, reflection: reflection, complete: complete)
            dirty = false; saved = true
            return true
        } catch { self.error = "We couldn't save your study. Keep the pad open and try again. \(error.localizedDescription)"; return false }
    }
}
