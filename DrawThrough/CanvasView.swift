import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct CanvasView: View {
    @EnvironmentObject private var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    @State var project: ProjectSummary
    @State private var layers: [LayerItem] = []
    @State private var selection: UUID?
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var panel: CanvasPanel?
    @State private var traceLocked = false
    @State private var showGrid = false
    @State private var background = DTTheme.warmPaper
    @State private var hasLoaded = false
    @State private var showDeleteConfirmation = false
    @State private var showSavedFeedback = false
    @State private var canvasOffset: CGSize = .zero
    @State private var canvasScale: CGFloat = 1
    @State private var viewportSize: CGSize = .zero
    @State private var thumbnailTask: Task<Void, Never>?
    @FocusState private var isEditingName: Bool

    enum CanvasPanel: String, Identifiable { case layers, adjust, view, export; var id: String { rawValue } }
    private var selectedIndex: Int? { layers.firstIndex { $0.id == selection } }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    background
                    LinearGradient(colors: [.white.opacity(0.22), DTTheme.sepia.opacity(0.07)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Canvas { context, size in
                        for i in 0..<120 {
                            let x = CGFloat((i * 67) % 103) / 103 * size.width
                            let y = CGFloat((i * 37) % 101) / 101 * size.height
                            context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)), with: .color(.black.opacity(0.025)))
                        }
                    }
                }.ignoresSafeArea()
                ZStack {
                    Color.clear.contentShape(Rectangle())
                    if layers.isEmpty {
                        PhotosPicker(selection: $photoItems, maxSelectionCount: 12, matching: .images) { EmptyCanvasHint() }.buttonStyle(.plain)
                    }
                    ForEach(layers) { layer in
                        if !layer.hidden { LayerCanvasItem(layer: binding(for: layer), selected: selection == layer.id, interactionEnabled: selection == nil || selection == layer.id, canvasSize: geo.size) { selection = layer.id } }
                    }
                }
                .background {
                    if showGrid {
                        GridOverlay()
                            .stroke(.black.opacity(0.08), lineWidth: 0.5)
                            .frame(width: geo.size.width * 3, height: geo.size.height * 3)
                            .allowsHitTesting(false)
                    }
                }
                .simultaneousGesture(SpatialTapGesture().onEnded { tap in selectLayer(at: tap.location, canvasSize: geo.size) })
                .scaleEffect(canvasScale).offset(canvasOffset)
                if traceLocked { LockedOverlay { unlock() } }
            }
            .safeAreaInset(edge: .top, spacing: 0) { topBar }
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .onAppear { viewportSize = geo.size }
            .onChange(of: geo.size) { _, value in viewportSize = value }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: photoItems) { _, items in Task { await importPhotos(items) } }
        .onChange(of: layers) { _, _ in autosave() }
        .onChange(of: showGrid) { _, _ in autosave() }
        .onChange(of: background) { _, _ in autosave() }
        .onChange(of: canvasOffset) { _, _ in autosave() }
        .onChange(of: canvasScale) { _, _ in autosave() }
        .onChange(of: project.name) { _, _ in autosave() }
        .sheet(item: $panel) { choice in panelView(choice) }
        .onAppear { loadComposition() }
        .onDisappear { saveComposition(feedback: false); saveThumbnailNow(); UIApplication.shared.isIdleTimerDisabled = false }
        .confirmationDialog("Delete this composition?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Composition", role: .destructive) { store.delete(project); dismiss() }
            Button("Cancel", role: .cancel) { }
        } message: { Text("This removes the project and all of its reference images.") }
        .overlay(alignment: .top) {
            if showSavedFeedback { Label("Composition saved", systemImage: "checkmark.circle.fill").font(.system(.caption, design: .serif, weight: .semibold)).padding(.horizontal, 14).padding(.vertical, 9).background(.ultraThinMaterial, in: Capsule()).padding(.top, 62).transition(.move(edge: .top).combined(with: .opacity)) }
        }
        .background { TwoFingerPanInstaller(isEnabled: !traceLocked && selection == nil) { delta in canvasOffset.width += delta.width; canvasOffset.height += delta.height } }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Label("Projects", systemImage: "chevron.left") }
            Spacer()
            HStack(spacing: 5) {
                TextField("Untitled Composition", text: $project.name)
                    .multilineTextAlignment(.center).font(.subheadline.weight(.semibold)).focused($isEditingName)
                Button { isEditingName = true } label: { Image(systemName: "pencil").font(.caption) }.accessibilityLabel("Edit project name")
            }.frame(maxWidth: 190)
            Spacer()
            Button { saveComposition(feedback: true); isEditingName = false } label: { Image(systemName: "checkmark.circle") }.accessibilityLabel("Save composition")
            Button { panel = .export } label: { Image(systemName: "square.and.arrow.up") }
            Button(role: .destructive) { showDeleteConfirmation = true } label: { Image(systemName: "trash") }.accessibilityLabel("Delete composition")
        }.font(.system(.subheadline, design: .serif)).foregroundStyle(DTTheme.ink)
            .padding(.horizontal, 16).padding(.vertical, 11)
            .background { Rectangle().fill(.ultraThinMaterial).overlay(DTTheme.warmPaper.opacity(0.34)) }
            .overlay(alignment: .bottom) { Rectangle().fill(DTTheme.line).frame(height: 0.5) }
    }

    private var bottomBar: some View {
        HStack(spacing: 4) {
            PhotosPicker(selection: $photoItems, maxSelectionCount: 12, matching: .images) { ToolLabel("Image", "plus") }
            Button { panel = .layers } label: { ToolLabel("Layers", "square.3.layers.3d") }
            Button { panel = .adjust } label: { ToolLabel("Adjust", "slider.horizontal.3") }
                .disabled(selection == nil)
                .foregroundStyle(selection == nil ? DTTheme.ink.opacity(0.32) : DTTheme.ink)
                .accessibilityHint(selection == nil ? "Select an image to adjust it" : "")
            Button { panel = .view } label: { ToolLabel("View", "viewfinder") }
            Button { traceLocked ? unlock() : lock() } label: { ToolLabel(traceLocked ? "Unlock" : "Lock", traceLocked ? "lock.open.fill" : "lock.fill") }.tint(DTTheme.clay)
        }.foregroundStyle(DTTheme.ink).padding(8)
            .background { WarmGlass(cornerRadius: 25) }
            .padding(.horizontal, 12).padding(.bottom, 8)
    }

    @ViewBuilder private func panelView(_ choice: CanvasPanel) -> some View {
        switch choice {
        case .layers: LayersPanel(layers: $layers, selection: $selection)
        case .adjust:
            if let i = selectedIndex { AdjustPanel(layer: $layers[i]) } else { Text("Select an image first").presentationDetents([.medium]) }
        case .view: ViewPanel(showGrid: $showGrid, background: $background, fitComposition: fitComposition, resetView: resetView)
        case .export: ExportPanel(image: renderComposition())
        }
    }

    private func binding(for layer: LayerItem) -> Binding<LayerItem> {
        guard let i = layers.firstIndex(where: { $0.id == layer.id }) else { return .constant(layer) }
        return $layers[i]
    }

    private func importPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                let sourceData = image.jpegData(compressionQuality: 0.92) ?? data
                let layer = LayerItem(id: UUID(), name: "Reference \(layers.count + 1)", image: image, sourceData: sourceData)
                layers.append(layer); selection = layer.id
            }
        }
        photoItems = []
    }

    private func lock() { selection = nil; traceLocked = true; UIApplication.shared.isIdleTimerDisabled = store.settings.keepAwake }
    private func unlock() { traceLocked = false; UIApplication.shared.isIdleTimerDisabled = false }
    private func loadComposition() {
        if let saved = store.loadDocument(for: project.id) {
            layers = saved.layers; showGrid = saved.showGrid; background = saved.background; canvasOffset = saved.canvasOffset; canvasScale = saved.canvasScale
        }
        hasLoaded = true
    }
    private func autosave() { guard hasLoaded else { return }; saveComposition(feedback: false) }
    private func saveComposition(feedback: Bool) {
        guard hasLoaded else { return }
        project.modifiedAt = .now
        store.update(project)
        store.saveDocument(for: project.id, layers: layers, showGrid: showGrid, background: background, canvasOffset: canvasOffset, canvasScale: canvasScale)
        scheduleThumbnail()
        if feedback {
            withAnimation { showSavedFeedback = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { withAnimation { showSavedFeedback = false } }
        }
    }
    private func scheduleThumbnail() {
        thumbnailTask?.cancel()
        thumbnailTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(450))
            guard !Task.isCancelled else { return }
            saveThumbnailNow()
        }
    }
    private func saveThumbnailNow() { if let image = renderComposition() { store.saveThumbnail(image, for: project.id) } }
    private func resetView() {
        withAnimation(.easeInOut(duration: 0.28)) { canvasOffset = .zero; canvasScale = 1 }
        panel = nil
    }
    private func fitComposition() {
        let visible = layers.filter { !$0.hidden }
        guard !visible.isEmpty, viewportSize.width > 0 else { resetView(); return }
        var bounds = CGRect.null
        for layer in visible {
            let maximum = CGSize(width: min(viewportSize.width * 0.68, 620), height: viewportSize.height * 0.68)
            let ratio = min(maximum.width / max(layer.image.size.width, 1), maximum.height / max(layer.image.size.height, 1))
            let size = CGSize(width: layer.image.size.width * ratio * layer.scale, height: layer.image.size.height * ratio * layer.scale)
            bounds = bounds.union(CGRect(x: layer.position.width - size.width / 2, y: layer.position.height - size.height / 2, width: size.width, height: size.height))
        }
        let scale = min(1, viewportSize.width * 0.84 / max(bounds.width, 1), viewportSize.height * 0.72 / max(bounds.height, 1))
        withAnimation(.easeInOut(duration: 0.32)) {
            canvasScale = max(scale, 0.18)
            canvasOffset = CGSize(width: -bounds.midX * canvasScale, height: -bounds.midY * canvasScale)
        }
        panel = nil
    }
    private func selectLayer(at location: CGPoint, canvasSize: CGSize) {
        let point = CGPoint(x: (location.x - canvasSize.width / 2) / canvasScale,
                            y: (location.y - canvasSize.height / 2) / canvasScale)
        let candidates = layers.reversed().filter { layer in
            guard !layer.hidden, !layer.locked, layer.opacity > 0.02 else { return false }
            let maximum = CGSize(width: min(canvasSize.width * 0.68, 620), height: canvasSize.height * 0.68)
            let ratio = min(maximum.width / max(layer.image.size.width, 1), maximum.height / max(layer.image.size.height, 1))
            let halfWidth = layer.image.size.width * ratio * layer.scale / 2
            let halfHeight = layer.image.size.height * ratio * layer.scale / 2
            let dx = point.x - layer.position.width
            let dy = point.y - layer.position.height
            let cosine = cos(-layer.rotation.radians), sine = sin(-layer.rotation.radians)
            let localX = dx * cosine - dy * sine
            let localY = dx * sine + dy * cosine
            return abs(localX) <= halfWidth && abs(localY) <= halfHeight
        }.map(\.id)
        guard !candidates.isEmpty else { selection = nil; return }
        if let current = selection, let index = candidates.firstIndex(of: current), candidates.count > 1 {
            selection = candidates[(index + 1) % candidates.count]
        } else {
            selection = candidates[0]
        }
    }
    private func renderComposition() -> UIImage? {
        let renderer = ImageRenderer(content: ZStack { background; ForEach(layers.filter { !$0.hidden }) { layer in Image(uiImage: FilterEngine.process(layer)).resizable().scaledToFit().frame(width: 500).scaleEffect(layer.scale).rotationEffect(layer.rotation).offset(layer.position).opacity(layer.opacity) } }.frame(width: 1200, height: 1600))
        renderer.scale = 1; return renderer.uiImage
    }
}

struct ToolLabel: View { let title, icon: String; init(_ title: String, _ icon: String) { self.title = title; self.icon = icon }; var body: some View { VStack(spacing: 4) { Image(systemName: icon).font(.body.weight(.light)); Text(title.uppercased()).font(.system(size: 8, weight: .semibold, design: .serif)).tracking(0.7) }.frame(maxWidth: .infinity).padding(.vertical, 5) } }

struct EmptyCanvasHint: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Image("ReferenceBust").resizable().scaledToFill().frame(width: 94, height: 116).clipShape(RoundedRectangle(cornerRadius: 9)).rotationEffect(.degrees(-7)).offset(x: -58, y: 4)
                Image("ReferenceHand").resizable().scaledToFill().frame(width: 88, height: 108).clipShape(RoundedRectangle(cornerRadius: 9)).rotationEffect(.degrees(7)).offset(x: 58, y: 7)
                Image("ReferenceFlower").resizable().scaledToFill().frame(width: 108, height: 132).clipShape(RoundedRectangle(cornerRadius: 11)).shadow(color: .black.opacity(0.15), radius: 9, y: 5)
                Circle().fill(DTTheme.ink).frame(width: 38, height: 38).overlay { Image(systemName: "plus").font(.headline).foregroundStyle(DTTheme.vellum) }.offset(x: 58, y: 51)
            }.frame(width: 250, height: 145)
            Text("Add your first reference").font(DTTheme.title(27))
            Text("Tap anywhere here to choose images").font(.system(.subheadline, design: .serif, weight: .semibold)).foregroundStyle(DTTheme.clay)
            Text("Then drag, pinch and rotate to compose.").font(.system(.caption, design: .serif)).foregroundStyle(DTTheme.ink.opacity(0.50))
        }.padding(.horizontal, 30).padding(.vertical, 25).vellumSurface(radius: 24).foregroundStyle(DTTheme.ink).contentShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct GridOverlay: Shape { func path(in rect: CGRect) -> Path { var p = Path(); let step: CGFloat = 44; stride(from: 0, through: rect.width, by: step).forEach { p.move(to: CGPoint(x: $0, y: 0)); p.addLine(to: CGPoint(x: $0, y: rect.height)) }; stride(from: 0, through: rect.height, by: step).forEach { p.move(to: CGPoint(x: 0, y: $0)); p.addLine(to: CGPoint(x: rect.width, y: $0)) }; return p } }
