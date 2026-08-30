import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack { Form {
            Picker("Appearance", selection: $store.settings.appearance) { ForEach(AppearanceChoice.allCases, id: \.self) { Text($0.rawValue).tag($0) } }
            Picker("Default canvas", selection: $store.settings.defaultCanvas) { ForEach(CanvasKind.allCases, id: \.self) { Text($0.rawValue).tag($0) } }
            Toggle("Keep screen awake while locked", isOn: $store.settings.keepAwake)
            Toggle("Show alignment guides", isOn: $store.settings.guides)
            Toggle("Haptics", isOn: $store.settings.haptics)
            Section { Button("Show onboarding again") { UserDefaults.standard.set(false, forKey: "hasSeenOnboarding"); dismiss() }; LabeledContent("Version", value: "1.0") }
        }.parchmentList().navigationTitle("Settings").toolbar { Button("Done") { dismiss() } } }
    }
}

struct TipsView: View {
    @Environment(\.dismiss) private var dismiss
    let tips = [("doc.text", "Using paper safely", "Use thin paper, avoid pressing hard, and keep liquids away from the device."), ("wand.and.stars", "Creating clean contours", "Choose Outline, then raise contrast until the important edges read clearly."), ("square.3.layers.3d", "Combining references", "Lower opacity and reorder layers to blend several sources into one composition."), ("grid", "Working with grids", "Turn on the grid before locking to transfer proportions more accurately.")]
    var body: some View { NavigationStack { List(tips, id: \.1) { tip in HStack(alignment: .top, spacing: 14) { Image(systemName: tip.0).font(.title2.weight(.light)).foregroundStyle(DTTheme.clay).frame(width: 32); VStack(alignment: .leading, spacing: 5) { Text(tip.1).font(.system(.headline, design: .serif)); Text(tip.2).font(.system(.subheadline, design: .serif)).foregroundStyle(.secondary).lineSpacing(2) } }.padding(.vertical, 9) }.parchmentList().navigationTitle("Learn").toolbar { Button("Done") { dismiss() } } } }
}
