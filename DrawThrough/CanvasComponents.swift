import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct LayerCanvasItem: View {
    @Binding var layer: LayerItem
    let selected: Bool
    let canvasSize: CGSize
    let select: () -> Void
    @GestureState private var drag: CGSize = .zero
    @GestureState private var zoom: CGFloat = 1
    @GestureState private var turn: Angle = .zero

    var body: some View {
        Image(uiImage: FilterEngine.process(layer)).resizable().scaledToFit()
            .frame(maxWidth: min(canvasSize.width * 0.68, 620), maxHeight: canvasSize.height * 0.68)
            .opacity(layer.opacity).brightness(layer.brightness).contrast(layer.contrast)
            .overlay { if selected { RoundedRectangle(cornerRadius: 3).stroke(DTTheme.ink, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])) } }
            .scaleEffect(layer.scale * zoom).rotationEffect(layer.rotation + turn).offset(x: layer.position.width + drag.width, y: layer.position.height + drag.height)
            .contentShape(Rectangle()).onTapGesture(perform: select)
            .gesture(layer.locked ? nil : dragGesture.simultaneously(with: magnifyGesture).simultaneously(with: rotateGesture))
            .accessibilityLabel(layer.name)
    }
    private var dragGesture: some Gesture { DragGesture().updating($drag) { value, state, _ in state = value.translation }.onEnded { layer.position.width += $0.translation.width; layer.position.height += $0.translation.height } }
    private var magnifyGesture: some Gesture { MagnificationGesture().updating($zoom) { value, state, _ in state = value }.onEnded { layer.scale = min(max(layer.scale * $0, 0.15), 6) } }
    private var rotateGesture: some Gesture { RotationGesture().updating($turn) { value, state, _ in state = value }.onEnded { layer.rotation += $0 } }
}

enum FilterEngine {
    static let context = CIContext()
    static func process(_ layer: LayerItem) -> UIImage {
        guard layer.mode != .color, let input = CIImage(image: layer.image) else { return layer.image }
        let output: CIImage?
        if layer.mode == .monochrome {
            let filter = CIFilter.photoEffectMono(); filter.inputImage = input; output = filter.outputImage
        } else {
            let edges = CIFilter.edges(); edges.inputImage = input.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0]); edges.intensity = 7
            output = edges.outputImage?.applyingFilter("CIColorInvert")
        }
        guard let result = output, let cg = context.createCGImage(result, from: result.extent) else { return layer.image }
        return UIImage(cgImage: cg, scale: layer.image.scale, orientation: layer.image.imageOrientation)
    }
}

struct LockedOverlay: View {
    let unlock: () -> Void
    @State private var progress = 0.0
    var body: some View {
        VStack { Spacer(); ZStack { Circle().stroke(.black.opacity(0.15), lineWidth: 4); Circle().trim(from: 0, to: progress).stroke(DTTheme.ink, style: StrokeStyle(lineWidth: 4, lineCap: .round)).rotationEffect(.degrees(-90)); Image(systemName: "lock.fill") }.frame(width: 48, height: 48)
            .onLongPressGesture(minimumDuration: 2, pressing: { pressing in withAnimation(.linear(duration: pressing ? 2 : 0.2)) { progress = pressing ? 1 : 0 } }, perform: unlock)
            Text("Hold to unlock").font(.caption).foregroundStyle(.secondary)
        }.padding(.bottom, 30).frame(maxWidth: .infinity).contentShape(Rectangle())
    }
}

struct LayersPanel: View {
    @Binding var layers: [LayerItem]
    @Binding var selection: UUID?
    var body: some View {
        NavigationStack { List { ForEach($layers.reversed()) { $layer in
            HStack { Button { layer.hidden.toggle() } label: { Image(systemName: layer.hidden ? "eye.slash" : "eye") }; Image(uiImage: layer.image).resizable().scaledToFill().frame(width: 45, height: 45).clipShape(RoundedRectangle(cornerRadius: 6)); VStack(alignment: .leading) { TextField("Layer", text: $layer.name); Text("\(Int(layer.opacity * 100))% · \(layer.mode.rawValue)").font(.caption).foregroundStyle(.secondary) }; Spacer(); Button { layer.locked.toggle() } label: { Image(systemName: layer.locked ? "lock.fill" : "lock.open") } }
                .contentShape(Rectangle()).onTapGesture { selection = layer.id }
            }.onMove { source, destination in layers.move(fromOffsets: source, toOffset: max(0, layers.count - destination)) }.onDelete { offsets in let ids = offsets.map { Array(layers.reversed())[$0].id }; layers.removeAll { ids.contains($0.id) } }
        }.navigationTitle("Layers").navigationBarTitleDisplayMode(.inline).toolbar { EditButton() } }.presentationDetents([.medium, .large])
    }
}

struct AdjustPanel: View {
    @Binding var layer: LayerItem
    var body: some View {
        NavigationStack { Form {
            Picker("Image style", selection: $layer.mode) { ForEach(ImageMode.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
            VStack(alignment: .leading) { HStack { Text("Opacity"); Spacer(); Text("\(Int(layer.opacity * 100))%").foregroundStyle(.secondary) }; Slider(value: $layer.opacity, in: 0...1) }
            VStack(alignment: .leading) { HStack { Text("Brightness"); Spacer(); Text("\(Int(layer.brightness * 100))").foregroundStyle(.secondary) }; Slider(value: $layer.brightness, in: -0.5...0.5) }
            VStack(alignment: .leading) { HStack { Text("Contrast"); Spacer(); Text(String(format: "%.1f", layer.contrast)).foregroundStyle(.secondary) }; Slider(value: $layer.contrast, in: 0.5...2) }
            Button("Reset adjustments") { layer.opacity = 1; layer.brightness = 0; layer.contrast = 1; layer.mode = .color }
        }.navigationTitle("Adjust").navigationBarTitleDisplayMode(.inline) }.presentationDetents([.medium, .large])
    }
}

struct ViewPanel: View {
    @Binding var showGrid: Bool
    @Binding var background: Color
    var body: some View { NavigationStack { Form { Toggle("Grid", isOn: $showGrid); Section("Background") { HStack { ForEach([DTTheme.warmPaper, .white, Color(white: 0.72), .black], id: \.self) { color in Circle().fill(color).stroke(.secondary, lineWidth: 1).frame(width: 36, height: 36).onTapGesture { background = color } } } }; Section { Button("Fit composition") { }; Button("Reset view") { } } }.navigationTitle("View & Guides").navigationBarTitleDisplayMode(.inline) }.presentationDetents([.medium]) }
}

struct ExportPanel: View {
    let image: UIImage?
    var body: some View { NavigationStack { List { if let image { ShareLink(item: Image(uiImage: image), preview: SharePreview("Draw Through Composition", image: Image(uiImage: image))) { Label("Share composition", systemImage: "square.and.arrow.up") }; Button { UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) } label: { Label("Save to Photos", systemImage: "photo") } } else { ContentUnavailableView("Nothing to export", systemImage: "photo") } }.navigationTitle("Export").navigationBarTitleDisplayMode(.inline) }.presentationDetents([.medium]) }
}
