import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ProjectStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PaperBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    EditorialHeader(kicker: "DRAW THROUGH", title: "Settings", subtitle: "Shape the studio around the way you draw.") { dismiss() }
                    SettingsSection(title: "STUDIO") {
                        MenuRow(icon: "rectangle.on.rectangle.angled", title: "Default canvas", value: store.settings.defaultCanvas.rawValue) {
                            ForEach(CanvasKind.allCases, id: \.self) { canvas in Button(canvas.rawValue) { store.settings.defaultCanvas = canvas } }
                        }
                    }
                    SettingsSection(title: "TRACE MODE") {
                        ToggleRow(icon: "sun.max", title: "Keep screen awake", detail: "While the canvas is locked", isOn: $store.settings.keepAwake)
                        FineDivider()
                        ToggleRow(icon: "viewfinder", title: "Alignment guides", detail: "Show while composing", isOn: $store.settings.guides)
                        FineDivider()
                        ToggleRow(icon: "waveform", title: "Haptic touches", detail: "Quiet physical feedback", isOn: $store.settings.haptics)
                    }
                    SettingsSection(title: "ABOUT") {
                        Button { UserDefaults.standard.set(false, forKey: "hasSeenOnboarding"); dismiss() } label: {
                            SettingLabel(icon: "arrow.counterclockwise", title: "Replay introduction", detail: "Return to the three opening chapters")
                        }.buttonStyle(.plain)
                        FineDivider()
                        HStack {
                            SettingLabel(icon: "info", title: "Draw Through", detail: "Made for slow, careful looking")
                        }
                    }
                    Text("A quiet tool for turning references into drawings.").font(.system(.footnote, design: .serif)).italic().foregroundStyle(DTTheme.ink.opacity(0.45)).frame(maxWidth: .infinity).padding(.vertical, 8)
                }.padding(.horizontal, 22).padding(.bottom, 30)
            }
        }
    }
}

struct TipsView: View {
    @Environment(\.dismiss) private var dismiss
    private let tips = [
        ("01", "doc.text", "Paper over glass", "Choose thin, smooth paper and let the illuminated image do the work. Draw lightly—there is no need to press into the screen."),
        ("02", "wand.and.stars", "Find the essential line", "Switch to Outline, then balance contrast and opacity until only the forms you truly need remain."),
        ("03", "square.3.layers.3d", "Compose from fragments", "A face, a gesture, and a flower can become one image. Overlap references and let empty space hold them together."),
        ("04", "circle.grid.cross", "Measure before tracing", "Use a grid for proportion, then hide it before locking if you want a cleaner drawing surface."),
        ("05", "circle.lefthalf.filled", "Let opacity breathe", "Lower an image until it feels like a memory beneath the paper. The faintest useful reference is often the best one.")
    ]

    var body: some View {
        ZStack {
            PaperBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    EditorialHeader(kicker: "FIELD NOTES", title: "Learn", subtitle: "Small rituals for clearer, more expressive tracing.") { dismiss() }
                    ForEach(tips, id: \.0) { tip in
                        HStack(alignment: .top, spacing: 17) {
                            ZStack {
                                Circle().fill(LinearGradient(colors: [DTTheme.vellum.opacity(0.85), DTTheme.parchment.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                Image(systemName: tip.1).font(.system(size: 20, weight: .light)).foregroundStyle(DTTheme.clay)
                            }.frame(width: 52, height: 52).overlay { Circle().stroke(.white.opacity(0.58), lineWidth: 0.7) }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NOTE  \(tip.0)").font(DTTheme.smallCaps).tracking(1.5).foregroundStyle(DTTheme.sepia.opacity(0.72))
                                Text(tip.2).font(DTTheme.title(23)).foregroundStyle(DTTheme.ink)
                                Text(tip.3).font(.system(.subheadline, design: .serif)).foregroundStyle(DTTheme.ink.opacity(0.60)).lineSpacing(4)
                            }
                        }.padding(19).frame(maxWidth: .infinity, alignment: .leading).vellumSurface(radius: 22)
                    }
                    HStack(spacing: 12) { Rectangle().fill(DTTheme.line).frame(height: 0.5); Image(systemName: "pencil.and.outline").font(.caption).foregroundStyle(DTTheme.clay.opacity(0.55)); Rectangle().fill(DTTheme.line).frame(height: 0.5) }.padding(.vertical, 14)
                }.padding(.horizontal, 22).padding(.bottom, 26)
            }
        }
    }
}

private struct EditorialHeader: View {
    let kicker: String; let title: String; let subtitle: String; let close: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(kicker).font(DTTheme.smallCaps).tracking(2.3).foregroundStyle(DTTheme.sepia.opacity(0.72)); Spacer()
                Button(action: close) { Image(systemName: "xmark").font(.system(size: 12, weight: .semibold)).frame(width: 36, height: 36).background(.white.opacity(0.33), in: Circle()).overlay { Circle().stroke(.white.opacity(0.5), lineWidth: 0.6) } }.foregroundStyle(DTTheme.ink)
            }
            Text(title).font(DTTheme.display(46)).foregroundStyle(DTTheme.ink)
            Text(subtitle).font(.system(.body, design: .serif)).foregroundStyle(DTTheme.ink.opacity(0.57)).lineSpacing(3)
        }.padding(.top, 20).padding(.bottom, 5)
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String; let content: Content
    init(title: String, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }
    var body: some View { VStack(alignment: .leading, spacing: 10) { Text(title).font(DTTheme.smallCaps).tracking(1.8).foregroundStyle(DTTheme.sepia.opacity(0.72)).padding(.leading, 4); VStack(spacing: 0) { content }.padding(.horizontal, 17).vellumSurface(radius: 20) } }
}

private struct SettingLabel: View {
    let icon: String; let title: String; let detail: String
    var body: some View { HStack(spacing: 13) { Image(systemName: icon).font(.system(size: 17, weight: .light)).foregroundStyle(DTTheme.clay).frame(width: 25); VStack(alignment: .leading, spacing: 3) { Text(title).font(.system(.body, design: .serif, weight: .semibold)).foregroundStyle(DTTheme.ink); Text(detail).font(.system(.caption, design: .serif)).foregroundStyle(DTTheme.ink.opacity(0.48)) } }.padding(.vertical, 14) }
}

private struct MenuRow<Content: View>: View {
    let icon: String; let title: String; let value: String; let content: Content
    init(icon: String, title: String, value: String, @ViewBuilder content: () -> Content) { self.icon = icon; self.title = title; self.value = value; self.content = content() }
    var body: some View { HStack { SettingLabel(icon: icon, title: title, detail: value); Spacer(); Menu { content } label: { Image(systemName: "chevron.up.chevron.down").font(.caption2.weight(.semibold)).frame(width: 30, height: 30).background(DTTheme.parchment.opacity(0.55), in: Circle()) } } }
}

private struct ToggleRow: View {
    let icon: String; let title: String; let detail: String; @Binding var isOn: Bool
    var body: some View { HStack { SettingLabel(icon: icon, title: title, detail: detail); Spacer(); Toggle("", isOn: $isOn).labelsHidden().tint(DTTheme.ink) } }
}

private struct FineDivider: View { var body: some View { Rectangle().fill(DTTheme.line).frame(height: 0.5).padding(.leading, 38) } }
