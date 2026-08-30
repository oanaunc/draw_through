import SwiftUI
import PhotosUI

struct HomeView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var route: ProjectSummary?
    @State private var showCanvasSetup = false
    @State private var showSettings = false
    @State private var showTips = false
    @State private var filter = 0

    var filtered: [ProjectSummary] { filter == 1 ? store.projects.filter(\.favorite) : store.projects }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Draw Through").font(.system(size: 38, weight: .medium, design: .serif)).italic()
                            Spacer()
                            Button { showTips = true } label: { Image(systemName: "lightbulb") }
                            Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        }.font(.title3).foregroundStyle(DTTheme.ink)
                        Button { showCanvasSetup = true } label: { Label("New Canvas", systemImage: "plus").frame(maxWidth: .infinity) }.buttonStyle(InkButtonStyle())
                        Picker("Projects", selection: $filter) { Text("Recent").tag(0); Text("Favorites").tag(1) }.pickerStyle(.segmented)
                        if filtered.isEmpty {
                            ContentUnavailableView("Your canvas is waiting", systemImage: "scribble.variable", description: Text("Create a canvas, add references, and arrange the drawing you want to make."))
                                .frame(maxWidth: .infinity).padding(.top, 50)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 16)], spacing: 18) {
                                ForEach(filtered) { project in ProjectCard(project: project) { route = project } }
                            }
                        }
                    }.padding(20)
                }
            }
            .navigationDestination(item: $route) { CanvasView(project: $0) }
            .sheet(isPresented: $showCanvasSetup) { NewCanvasSheet { route = store.create(kind: $0); showCanvasSetup = false } }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showTips) { TipsView() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct ProjectCard: View {
    @EnvironmentObject private var store: ProjectStore
    let project: ProjectSummary
    let open: () -> Void
    var body: some View {
        Button(action: open) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15).fill(.white.opacity(0.45))
                    Image(systemName: "photo.artframe").font(.system(size: 44, weight: .thin)).foregroundStyle(DTTheme.clay)
                }.aspectRatio(1.18, contentMode: .fit)
                Text(project.name).font(.headline).lineLimit(1)
                Text(project.modifiedAt, style: .relative).font(.caption).foregroundStyle(.secondary)
            }.padding(10).background(.white.opacity(0.3), in: RoundedRectangle(cornerRadius: 18))
        }.buttonStyle(.plain).contextMenu {
            Button { var copy = project; copy.id = UUID(); copy.name += " Copy"; store.projects.insert(copy, at: 0) } label: { Label("Duplicate", systemImage: "plus.square.on.square") }
            Button { var value = project; value.favorite.toggle(); store.update(value) } label: { Label(project.favorite ? "Unfavorite" : "Favorite", systemImage: "heart") }
            Button(role: .destructive) { store.delete(project) } label: { Label("Delete", systemImage: "trash") }
        }
    }
}

struct NewCanvasSheet: View {
    let create: (CanvasKind) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selected = CanvasKind.infinite
    var body: some View {
        NavigationStack {
            List {
                Section("Choose a surface") {
                    ForEach(CanvasKind.allCases, id: \.self) { kind in
                        Button { selected = kind } label: {
                            HStack { Image(systemName: kind == .infinite ? "infinity" : "rectangle"); Text(kind.rawValue); Spacer(); if selected == kind { Image(systemName: "checkmark.circle.fill") } }
                        }.foregroundStyle(DTTheme.ink)
                    }
                }
            }.scrollContentBackground(.hidden).background(DTTheme.warmPaper)
                .navigationTitle("New Canvas").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Create") { create(selected) }.fontWeight(.semibold) } }
        }.presentationDetents([.medium])
    }
}

