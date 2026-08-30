import SwiftUI

enum ScreenshotScene {
    static var launchScene: Int? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-screenshot-scene"), args.indices.contains(index + 1) else { return nil }
        return Int(args[index + 1])
    }
}

struct ScreenshotShowcaseView: View {
    let scene: Int
    var body: some View {
        Group {
            switch scene {
            case 1: OnboardingView { }
            case 2: DemoHomeView()
            case 3: DemoCanvasView(panel: nil)
            case 4: DemoCanvasView(panel: .adjust)
            case 5: DemoCanvasView(panel: .layers)
            case 6: DemoCanvasView(panel: .guides)
            case 7: DemoCanvasView(panel: .locked)
            case 8: DemoCanvasView(panel: .export)
            case 9: TipsView()
            default: SettingsView()
            }
        }.preferredColorScheme(.light)
    }
}

private struct DemoHomeView: View {
    let projects = [("Reference Study", "ReferenceBust", "TODAY, 9:41"), ("Floral Composition", "ReferenceFlower", "YESTERDAY"), ("Gesture Notes", "ReferenceHand", "AUGUST 28")]
    var body: some View {
        ZStack {
            PaperBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) { Text("DRAWING STUDIO").font(DTTheme.smallCaps).tracking(2.4).foregroundStyle(DTTheme.clay.opacity(0.72)); Text("Draw Through").font(DTTheme.display(43)).italic() }
                        Spacer(); Image(systemName: "lightbulb").demoCircle(); Image(systemName: "gearshape").demoCircle()
                    }.foregroundStyle(DTTheme.ink)
                    Label("New Canvas", systemImage: "plus").frame(maxWidth: .infinity).padding(.vertical, 14).font(.system(.headline, design: .serif, weight: .semibold)).foregroundStyle(DTTheme.vellum).background(DTTheme.ink, in: RoundedRectangle(cornerRadius: 14))
                    HStack { Text("YOUR CANVASES").font(DTTheme.smallCaps).tracking(1.7); Spacer(); Text("RECENT   ·   FAVORITES").font(.system(size: 10, weight: .semibold, design: .serif)).tracking(1).foregroundStyle(DTTheme.clay) }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 175), spacing: 18)], spacing: 18) {
                        ForEach(projects, id: \.0) { item in
                            VStack(alignment: .leading, spacing: 10) {
                                Image(item.1).resizable().scaledToFill().frame(height: 210).clipShape(RoundedRectangle(cornerRadius: 15)).overlay(alignment: .topTrailing) { Image(systemName: item.0 == "Reference Study" ? "heart.fill" : "heart").padding(10).background(.ultraThinMaterial, in: Circle()).padding(8) }
                                Text(item.0).font(.system(.headline, design: .serif, weight: .semibold)); Text(item.2).font(DTTheme.smallCaps).tracking(1).foregroundStyle(.secondary)
                            }.padding(10).vellumSurface(radius: 18)
                        }
                    }
                }.padding(22)
            }
        }
    }
}

private enum DemoPanel { case adjust, layers, guides, locked, export }

private struct DemoCanvasView: View {
    let panel: DemoPanel?
    @Environment(\.horizontalSizeClass) private var sizeClass
    var body: some View {
        ZStack {
            PaperBackground()
            if panel == .guides { DemoGrid().stroke(DTTheme.ink.opacity(0.12), lineWidth: 0.7).ignoresSafeArea() }
            composition.padding(.horizontal, sizeClass == .regular ? 110 : 22).padding(.vertical, 95)
            topBar; bottomBar
            panelOverlay
        }
    }

    private var composition: some View {
        GeometryReader { geo in
            ZStack {
                Image("ReferenceBust").resizable().scaledToFit().frame(width: geo.size.width * 0.56).rotationEffect(.degrees(-3)).offset(x: -geo.size.width * 0.20, y: -geo.size.height * 0.06).shadow(color: .black.opacity(0.16), radius: 13, y: 8)
                Image("ReferenceFlower").resizable().scaledToFit().frame(width: geo.size.width * 0.47).rotationEffect(.degrees(4)).offset(x: geo.size.width * 0.23, y: geo.size.height * 0.02).shadow(color: .black.opacity(0.14), radius: 13, y: 8)
                Image("ReferenceHand").resizable().scaledToFit().frame(width: geo.size.width * 0.35).rotationEffect(.degrees(-7)).offset(x: geo.size.width * 0.16, y: geo.size.height * 0.28).opacity(0.88).shadow(color: .black.opacity(0.13), radius: 12, y: 7)
                if panel == nil { DemoSelectionFrame().frame(width: geo.size.width * 0.47, height: geo.size.width * 0.47 * 1.5).rotationEffect(.degrees(4)).offset(x: geo.size.width * 0.23, y: geo.size.height * 0.02) }
            }
        }
    }

    private var topBar: some View { VStack { HStack { Label("Projects", systemImage: "chevron.left"); Spacer(); HStack(spacing: 5) { Text("Atelier Composition").font(.system(.subheadline, design: .serif, weight: .semibold)); Image(systemName: "pencil").font(.caption) }; Spacer(); Image(systemName: "checkmark.circle"); Image(systemName: "square.and.arrow.up"); Image(systemName: "trash") }.padding(.horizontal, 18).padding(.vertical, 13).background(.ultraThinMaterial).overlay(alignment: .bottom) { Rectangle().fill(DTTheme.line).frame(height: 0.5) }; Spacer() }.foregroundStyle(DTTheme.ink) }
    private var bottomBar: some View { VStack { Spacer(); HStack { DemoTool("Image", "plus"); DemoTool("Layers", "square.3.layers.3d"); DemoTool("Adjust", "slider.horizontal.3"); DemoTool("View", "viewfinder"); DemoTool("Lock", "lock.fill") }.padding(9).background { WarmGlass(cornerRadius: 26) }.padding(.horizontal, sizeClass == .regular ? 220 : 14).padding(.bottom, 10) }.foregroundStyle(DTTheme.ink) }

    @ViewBuilder private var panelOverlay: some View {
        switch panel {
        case .adjust: DemoSheet(title: "Adjust") { VStack(spacing: 20) { HStack { mode("Color", true); mode("B&W", false); mode("Outline", false) }; DemoSlider(title: "Opacity", value: "68%", fill: 0.68); DemoSlider(title: "Brightness", value: "+8", fill: 0.56); DemoSlider(title: "Contrast", value: "1.2", fill: 0.62) } }
        case .layers: DemoSheet(title: "Layers") { VStack(spacing: 0) { DemoLayer(image: "ReferenceHand", title: "Hand study", value: "88%"); FineLine(); DemoLayer(image: "ReferenceFlower", title: "Peony", value: "68%"); FineLine(); DemoLayer(image: "ReferenceBust", title: "Portrait", value: "100%") } }
        case .guides: DemoSheet(title: "View & Guides") { VStack(spacing: 0) { DemoToggleRow("Grid", true); FineLine(); DemoToggleRow("Alignment guides", true); FineLine(); DemoToggleRow("Perspective grid", false); HStack { Text("BACKGROUND").font(DTTheme.smallCaps).tracking(1.5); Spacer(); ForEach([DTTheme.warmPaper, DTTheme.parchment, .gray, DTTheme.ink], id: \.self) { Circle().fill($0).frame(width: 28, height: 28).overlay { Circle().stroke(.white, lineWidth: 1) } } }.padding(.top, 18) } }
        case .locked: VStack { Spacer(); ZStack { Circle().fill(.ultraThinMaterial).frame(width: 76, height: 76); Circle().stroke(DTTheme.ink.opacity(0.20), lineWidth: 4).frame(width: 62, height: 62); Image(systemName: "lock.fill").font(.title2) }; Text("Canvas locked").font(DTTheme.title(24)); Text("Hold to unlock").font(.system(.caption, design: .serif)).foregroundStyle(.secondary) }.padding(.bottom, 45)
        case .export: DemoSheet(title: "Export") { VStack(spacing: 12) { HStack(spacing: 12) { exportTile("PNG", "photo"); exportTile("JPEG", "photo.on.rectangle"); exportTile("PDF", "doc") }; DemoAction("Save to Photos", "photo.badge.arrow.down"); DemoAction("Share composition", "square.and.arrow.up"); DemoAction("Export outlines only", "scribble.variable") } }
        case nil: EmptyView()
        }
    }
    private func mode(_ title: String, _ active: Bool) -> some View { Text(title).font(.system(.subheadline, design: .serif, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 10).foregroundStyle(active ? DTTheme.vellum : DTTheme.ink).background(active ? DTTheme.ink : DTTheme.parchment.opacity(0.45), in: Capsule()) }
    private func exportTile(_ title: String, _ icon: String) -> some View { VStack(spacing: 9) { Image(systemName: icon).font(.title2.weight(.light)); Text(title).font(DTTheme.smallCaps) }.frame(maxWidth: .infinity).padding(.vertical, 18).vellumSurface(radius: 14) }
    private func DemoAction(_ title: String, _ icon: String) -> some View { HStack { Image(systemName: icon).frame(width: 28); Text(title).font(.system(.body, design: .serif)); Spacer(); Image(systemName: "chevron.right").font(.caption) }.padding(15).background(.white.opacity(0.28), in: RoundedRectangle(cornerRadius: 14)) }
}

private struct DemoSheet<Content: View>: View {
    let title: String
    let content: Content
    init(title: String, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 18) {
                Capsule().fill(DTTheme.ink.opacity(0.16)).frame(width: 38, height: 4)
                Text(title).font(DTTheme.title(30)).frame(maxWidth: .infinity, alignment: .leading)
                content
            }
            .padding(22)
            .background { PaperBackground().clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous)) }
            .overlay { RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.55), lineWidth: 0.8) }
            .shadow(color: .black.opacity(0.20), radius: 25, y: 8)
            .padding(.horizontal, 10).padding(.bottom, 3)
        }
    }
}
private struct DemoTool: View { let title, icon: String; init(_ title: String, _ icon: String) { self.title = title; self.icon = icon }; var body: some View { VStack(spacing: 4) { Image(systemName: icon).font(.body.weight(.light)); Text(title.uppercased()).font(.system(size: 8, weight: .semibold, design: .serif)).tracking(0.7) }.frame(maxWidth: .infinity).padding(.vertical, 5) } }
private struct DemoSlider: View { let title, value: String; let fill: CGFloat; var body: some View { VStack(spacing: 9) { HStack { Text(title).font(.system(.body, design: .serif)); Spacer(); Text(value).font(.system(.subheadline, design: .serif)).foregroundStyle(.secondary) }; GeometryReader { geo in ZStack(alignment: .leading) { Capsule().fill(DTTheme.ink.opacity(0.12)).frame(height: 3); Capsule().fill(DTTheme.ink).frame(width: geo.size.width * fill, height: 3); Circle().fill(DTTheme.ink).frame(width: 14, height: 14).offset(x: geo.size.width * fill - 7) } }.frame(height: 14) } } }
private struct DemoLayer: View { let image, title, value: String; var body: some View { HStack(spacing: 12) { Image(systemName: "eye"); Image(image).resizable().scaledToFill().frame(width: 48, height: 48).clipShape(RoundedRectangle(cornerRadius: 7)); VStack(alignment: .leading) { Text(title).font(.system(.body, design: .serif, weight: .semibold)); Text(value).font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "line.3.horizontal") }.padding(.vertical, 10) } }
private struct DemoToggleRow: View { let title: String; let on: Bool; init(_ title: String, _ on: Bool) { self.title = title; self.on = on }; var body: some View { HStack { Text(title).font(.system(.body, design: .serif)); Spacer(); Capsule().fill(on ? DTTheme.ink : DTTheme.ink.opacity(0.13)).frame(width: 45, height: 27).overlay(alignment: on ? .trailing : .leading) { Circle().fill(DTTheme.vellum).frame(width: 23, height: 23).padding(2) } }.padding(.vertical, 12) } }
private struct FineLine: View { var body: some View { Rectangle().fill(DTTheme.line).frame(height: 0.5) } }
private struct DemoGrid: Shape { func path(in rect: CGRect) -> Path { var path = Path(); stride(from: CGFloat(0), through: rect.width, by: 70).forEach { path.move(to: CGPoint(x: $0, y: 0)); path.addLine(to: CGPoint(x: $0, y: rect.height)) }; stride(from: CGFloat(0), through: rect.height, by: 70).forEach { path.move(to: CGPoint(x: 0, y: $0)); path.addLine(to: CGPoint(x: rect.width, y: $0)) }; return path } }
private struct DemoSelectionFrame: View { var body: some View { GeometryReader { geo in ZStack { RoundedRectangle(cornerRadius: 2).stroke(DTTheme.ink, style: StrokeStyle(lineWidth: 1.4, dash: [7, 5])); handle.position(x: 0, y: 0); handle.position(x: geo.size.width, y: 0); handle.position(x: 0, y: geo.size.height); handle.position(x: geo.size.width, y: geo.size.height) } } }; private var handle: some View { RoundedRectangle(cornerRadius: 2).fill(DTTheme.vellum).frame(width: 13, height: 13).overlay { RoundedRectangle(cornerRadius: 2).stroke(DTTheme.ink, lineWidth: 1.4) } } }
private extension View { func demoCircle() -> some View { frame(width: 38, height: 38).background(.white.opacity(0.28), in: Circle()) } }
