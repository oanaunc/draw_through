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
    @State private var showExporter = false

    enum CanvasPanel: String, Identifiable { case layers, adjust, view, export; var id: String { rawValue } }
    private var selectedIndex: Int? { layers.firstIndex { $0.id == selection } }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background.ignoresSafeArea()
                if showGrid { GridOverlay().stroke(.black.opacity(0.10), lineWidth: 0.7).ignoresSafeArea() }
                if layers.isEmpty { EmptyCanvasHint() }
                ForEach(layers) { layer in
                    if !layer.hidden { LayerCanvasItem(layer: binding(for: layer), selected: selection == layer.id, canvasSize: geo.size) { selection = layer.id } }
                }
                if traceLocked { LockedOverlay { unlock() } }
            }
            .safeAreaInset(edge: .top, spacing: 0) { if !traceLocked { topBar } }
            .safeAreaInset(edge: .bottom, spacing: 0) { if !traceLocked { bottomBar } }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .photosPicker(isPresented: Binding(get: { panel == nil && false }, set: { _ in }), selection: $photoItems, maxSelectionCount: 12, matching: .images)
        .onChange(of: photoItems) { _, items in Task { await importPhotos(items) } }
        .sheet(item: $panel) { choice in panelView(choice) }
        .onDisappear { project.modifiedAt = .now; store.update(project); UIApplication.shared.isIdleTimerDisabled = false }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Label("Projects", systemImage: "chevron.left") }
            Spacer()
            TextField("Untitled Composition", text: $project.name).multilineTextAlignment(.center).font(.subheadline.weight(.semibold)).frame(maxWidth: 220)
            Spacer()
            Button { panel = .export } label: { Image(systemName: "square.and.arrow.up") }
            Menu { Button("Select all") { selection = layers.last?.id }; Button("Clear selection") { selection = nil } } label: { Image(systemName: "ellipsis") }
        }.padding(.horizontal, 16).padding(.vertical, 11).background(.ultraThinMaterial)
    }

    private var bottomBar: some View {
        HStack(spacing: 4) {
            PhotosPicker(selection: $photoItems, maxSelectionCount: 12, matching: .images) { ToolLabel("Image", "plus") }
            Button { panel = .layers } label: { ToolLabel("Layers", "square.3.layers.3d") }
            Button { panel = .adjust } label: { ToolLabel("Adjust", "slider.horizontal.3") }.disabled(selection == nil)
            Button { panel = .view } label: { ToolLabel("View", "viewfinder") }
            Button { lock() } label: { ToolLabel("Lock", "lock.fill") }.tint(DTTheme.clay)
        }.padding(8).background(.ultraThinMaterial, in: Capsule()).padding(.horizontal, 12).padding(.bottom, 6)
    }

    @ViewBuilder private func panelView(_ choice: CanvasPanel) -> some View {
        switch choice {
        case .layers: LayersPanel(layers: $layers, selection: $selection)
        case .adjust:
            if let i = selectedIndex { AdjustPanel(layer: $layers[i]) } else { Text("Select an image first").presentationDetents([.medium]) }
        case .view: ViewPanel(showGrid: $showGrid, background: $background)
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
                let layer = LayerItem(id: UUID(), name: "Reference \(layers.count + 1)", image: image)
                layers.append(layer); selection = layer.id
            }
        }
        photoItems = []
    }

    private func lock() { selection = nil; traceLocked = true; UIApplication.shared.isIdleTimerDisabled = store.settings.keepAwake }
    private func unlock() { traceLocked = false; UIApplication.shared.isIdleTimerDisabled = false }
    private func renderComposition() -> UIImage? {
        let renderer = ImageRenderer(content: ZStack { background; ForEach(layers.filter { !$0.hidden }) { layer in Image(uiImage: FilterEngine.process(layer)).resizable().scaledToFit().frame(width: 500).scaleEffect(layer.scale).rotationEffect(layer.rotation).offset(layer.position).opacity(layer.opacity) } }.frame(width: 1200, height: 1600))
        renderer.scale = 1; return renderer.uiImage
    }
}

struct ToolLabel: View { let title, icon: String; init(_ title: String, _ icon: String) { self.title = title; self.icon = icon }; var body: some View { VStack(spacing: 3) { Image(systemName: icon).font(.body); Text(title).font(.caption2) }.frame(maxWidth: .infinity).padding(.vertical, 5) } }

struct EmptyCanvasHint: View { var body: some View { VStack(spacing: 12) { Image(systemName: "photo.badge.plus").font(.system(size: 42, weight: .thin)); Text("Add a reference image").font(.headline); Text("Then drag, pinch and rotate to compose.").font(.subheadline).foregroundStyle(.secondary) }.foregroundStyle(DTTheme.ink).allowsHitTesting(false) } }

struct GridOverlay: Shape { func path(in rect: CGRect) -> Path { var p = Path(); let step: CGFloat = 44; stride(from: 0, through: rect.width, by: step).forEach { p.move(to: CGPoint(x: $0, y: 0)); p.addLine(to: CGPoint(x: $0, y: rect.height)) }; stride(from: 0, through: rect.height, by: step).forEach { p.move(to: CGPoint(x: 0, y: $0)); p.addLine(to: CGPoint(x: rect.width, y: $0)) }; return p } }

