import SwiftUI
import UIKit

enum ImageMode: String, Codable, CaseIterable { case color = "Color", monochrome = "B&W", outline = "Outline" }
enum CanvasKind: String, Codable, CaseIterable { case infinite = "Infinite Canvas", a4 = "A4", a3 = "A3", a5 = "A5", square = "Square" }
enum AppearanceChoice: String, Codable, CaseIterable {
    case system = "System", light = "Light", dark = "Dark"
    var colorScheme: ColorScheme? { self == .system ? nil : (self == .light ? .light : .dark) }
}

struct AppSettings: Codable {
    var appearance = AppearanceChoice.system
    var defaultCanvas = CanvasKind.infinite
    var keepAwake = true
    var guides = true
    var haptics = true
}

struct LayerItem: Identifiable {
    let id: UUID
    var name: String
    var image: UIImage
    var position: CGSize = .zero
    var scale: CGFloat = 1
    var rotation: Angle = .zero
    var opacity: Double = 1
    var brightness: Double = 0
    var contrast: Double = 1
    var mode: ImageMode = .color
    var hidden = false
    var locked = false
}

struct ProjectSummary: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var modifiedAt: Date
    var canvas: CanvasKind
    var favorite: Bool
}

@MainActor final class ProjectStore: ObservableObject {
    @Published var projects: [ProjectSummary] = [] { didSet { save() } }
    @Published var settings = AppSettings() { didSet { saveSettings() } }

    init() {
        if let data = UserDefaults.standard.data(forKey: "projects"), let value = try? JSONDecoder().decode([ProjectSummary].self, from: data) { projects = value }
        if let data = UserDefaults.standard.data(forKey: "settings"), let value = try? JSONDecoder().decode(AppSettings.self, from: data) { settings = value }
    }

    func create(kind: CanvasKind) -> ProjectSummary {
        let project = ProjectSummary(id: UUID(), name: "Untitled Composition", modifiedAt: .now, canvas: kind, favorite: false)
        projects.insert(project, at: 0)
        return project
    }

    func update(_ project: ProjectSummary) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index] = project
    }

    func delete(_ project: ProjectSummary) { projects.removeAll { $0.id == project.id } }
    private func save() { if let data = try? JSONEncoder().encode(projects) { UserDefaults.standard.set(data, forKey: "projects") } }
    private func saveSettings() { if let data = try? JSONEncoder().encode(settings) { UserDefaults.standard.set(data, forKey: "settings") } }
}

