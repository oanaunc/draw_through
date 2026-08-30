import SwiftUI
import UIKit

enum ImageMode: String, Codable, CaseIterable { case color = "Color", monochrome = "B&W", outline = "Outline" }
enum CanvasKind: String, Codable, CaseIterable { case infinite = "Infinite Canvas", a4 = "A4", a3 = "A3", a5 = "A5", square = "Square" }
struct AppSettings: Codable {
    var defaultCanvas = CanvasKind.infinite
    var keepAwake = true
    var guides = true
    var haptics = true
}

struct LayerItem: Identifiable, Equatable {
    let id: UUID
    var name: String
    var image: UIImage
    var sourceData: Data
    var position: CGSize = .zero
    var scale: CGFloat = 1
    var rotation: Angle = .zero
    var opacity: Double = 1
    var brightness: Double = 0
    var contrast: Double = 1
    var mode: ImageMode = .color
    var hidden = false
    var locked = false

    static func == (lhs: LayerItem, rhs: LayerItem) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.position == rhs.position && lhs.scale == rhs.scale &&
        lhs.rotation == rhs.rotation && lhs.opacity == rhs.opacity && lhs.brightness == rhs.brightness &&
        lhs.contrast == rhs.contrast && lhs.mode == rhs.mode && lhs.hidden == rhs.hidden && lhs.locked == rhs.locked
    }
}

struct LayerRecord: Codable {
    var id: UUID
    var name: String
    var imageData: Data
    var positionX: Double
    var positionY: Double
    var scale: Double
    var rotationRadians: Double
    var opacity: Double
    var brightness: Double
    var contrast: Double
    var mode: ImageMode
    var hidden: Bool
    var locked: Bool

    init(_ layer: LayerItem) {
        id = layer.id; name = layer.name; imageData = layer.sourceData
        positionX = layer.position.width; positionY = layer.position.height; scale = layer.scale
        rotationRadians = layer.rotation.radians; opacity = layer.opacity; brightness = layer.brightness
        contrast = layer.contrast; mode = layer.mode; hidden = layer.hidden; locked = layer.locked
    }

    var layer: LayerItem? {
        guard let image = UIImage(data: imageData) else { return nil }
        return LayerItem(id: id, name: name, image: image, sourceData: imageData,
                         position: CGSize(width: positionX, height: positionY), scale: scale,
                         rotation: .radians(rotationRadians), opacity: opacity, brightness: brightness,
                         contrast: contrast, mode: mode, hidden: hidden, locked: locked)
    }
}

struct CanvasDocument: Codable {
    var layers: [LayerRecord] = []
    var showGrid = false
    var backgroundRed = 0.955
    var backgroundGreen = 0.925
    var backgroundBlue = 0.865
    var canvasOffsetX = 0.0
    var canvasOffsetY = 0.0
    var canvasScale = 1.0
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

    func delete(_ project: ProjectSummary) {
        projects.removeAll { $0.id == project.id }
        try? FileManager.default.removeItem(at: documentURL(project.id))
        try? FileManager.default.removeItem(at: thumbnailURL(project.id))
    }
    func saveThumbnail(_ image: UIImage, for projectID: UUID) {
        let size = CGSize(width: 600, height: 508)
        let format = UIGraphicsImageRendererFormat(); format.opaque = true; format.scale = 1
        let thumbnail = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            UIColor(DTTheme.warmPaper).setFill(); UIRectFill(CGRect(origin: .zero, size: size))
            let sourceRatio = image.size.width / max(image.size.height, 1)
            let targetRatio = size.width / size.height
            let drawSize = sourceRatio > targetRatio ? CGSize(width: size.height * sourceRatio, height: size.height) : CGSize(width: size.width, height: size.width / sourceRatio)
            image.draw(in: CGRect(x: (size.width - drawSize.width) / 2, y: (size.height - drawSize.height) / 2, width: drawSize.width, height: drawSize.height))
        }
        try? FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
        try? thumbnail.jpegData(compressionQuality: 0.88)?.write(to: thumbnailURL(projectID), options: .atomic)
        objectWillChange.send()
    }
    func loadThumbnail(for projectID: UUID) -> UIImage? { try? UIImage(data: Data(contentsOf: thumbnailURL(projectID))) }
    func saveDocument(for projectID: UUID, layers: [LayerItem], showGrid: Bool, background: Color, canvasOffset: CGSize, canvasScale: CGFloat) {
        let color = UIColor(background)
        var red: CGFloat = 0.955, green: CGFloat = 0.925, blue: CGFloat = 0.865, alpha: CGFloat = 1
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let document = CanvasDocument(layers: layers.map(LayerRecord.init), showGrid: showGrid,
                                      backgroundRed: red, backgroundGreen: green, backgroundBlue: blue,
                                      canvasOffsetX: canvasOffset.width, canvasOffsetY: canvasOffset.height, canvasScale: canvasScale)
        guard let data = try? JSONEncoder().encode(document) else { return }
        try? FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
        try? data.write(to: documentURL(projectID), options: .atomic)
    }

    func loadDocument(for projectID: UUID) -> (layers: [LayerItem], showGrid: Bool, background: Color, canvasOffset: CGSize, canvasScale: CGFloat)? {
        guard let data = try? Data(contentsOf: documentURL(projectID)),
              let document = try? JSONDecoder().decode(CanvasDocument.self, from: data) else { return nil }
        return (document.layers.compactMap(\.layer), document.showGrid,
                Color(red: document.backgroundRed, green: document.backgroundGreen, blue: document.backgroundBlue),
                CGSize(width: document.canvasOffsetX, height: document.canvasOffsetY), CGFloat(document.canvasScale))
    }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("DrawThrough/Compositions", isDirectory: true)
    }
    private func documentURL(_ id: UUID) -> URL { documentsDirectory.appendingPathComponent("\(id.uuidString).json") }
    private func thumbnailURL(_ id: UUID) -> URL { documentsDirectory.appendingPathComponent("\(id.uuidString)-thumbnail.jpg") }
    private func save() { if let data = try? JSONEncoder().encode(projects) { UserDefaults.standard.set(data, forKey: "projects") } }
    private func saveSettings() { if let data = try? JSONEncoder().encode(settings) { UserDefaults.standard.set(data, forKey: "settings") } }
}
