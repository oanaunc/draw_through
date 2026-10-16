import SwiftUI
import PencilKit

struct LessonStudy: Codable {
    var updatedAt: Date
    var completedAt: Date?
    var reflection: String
    var strokeCount: Int
}

struct LearningProgress: Codable {
    var studies: [Int: LessonStudy] = [:]
    var bookmarks: Set<Int> = []
}

@MainActor final class LearningStore: ObservableObject {
    @Published private(set) var progress: LearningProgress
    private let directory: URL
    private let defaults: UserDefaults
    private let key = "drawingLearningProgress.v1"

    init(directory: URL? = nil, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.directory = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DrawThrough/Studies", isDirectory: true)
        progress = defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(LearningProgress.self, from: $0) } ?? LearningProgress()
    }

    var completedCount: Int { progress.studies.values.filter { $0.completedAt != nil }.count }
    var nextLesson: DrawingLesson { DrawingLesson.all.first { progress.studies[$0.id]?.completedAt == nil } ?? DrawingLesson.all[0] }
    var recentLessons: [DrawingLesson] {
        DrawingLesson.all.filter { progress.studies[$0.id] != nil }.sorted {
            progress.studies[$0.id]!.updatedAt > progress.studies[$1.id]!.updatedAt
        }
    }

    func toggleBookmark(_ id: Int) {
        if progress.bookmarks.contains(id) { progress.bookmarks.remove(id) } else { progress.bookmarks.insert(id) }
        persistProgress()
    }

    func drawing(for id: Int) throws -> PKDrawing {
        let url = drawingURL(id)
        guard FileManager.default.fileExists(atPath: url.path) else { return PKDrawing() }
        return try PKDrawing(data: Data(contentsOf: url))
    }

    func save(_ drawing: PKDrawing, lessonID: Int, reflection: String, complete: Bool = false) throws {
        // A completion records a saved exercise, never just a visit to a reading page.
        if complete && drawing.strokes.isEmpty { throw StudyError.emptyDrawing }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try drawing.dataRepresentation().write(to: drawingURL(lessonID), options: .atomic)
        let previous = progress.studies[lessonID]
        progress.studies[lessonID] = LessonStudy(updatedAt: .now,
                                               completedAt: complete ? (previous?.completedAt ?? .now) : previous?.completedAt,
                                               reflection: reflection, strokeCount: drawing.strokes.count)
        persistProgress()
    }

    private func drawingURL(_ id: Int) -> URL { directory.appendingPathComponent("lesson-\(id).drawing") }
    private func persistProgress() {
        if let data = try? JSONEncoder().encode(progress) { defaults.set(data, forKey: key) }
    }

    enum StudyError: LocalizedError {
        case emptyDrawing
        var errorDescription: String? { "Make a few marks before completing your study." }
    }
}
