import XCTest
import PencilKit
import CryptoKit
@testable import DrawThrough

@MainActor final class LearningStoreTests: XCTestCase {
    private var folder: URL!
    private var defaults: UserDefaults!
    private var suite: String!
    override func setUp() async throws {
        folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        suite = "DrawThroughTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
    }
    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: folder)
        defaults.removePersistentDomain(forName: suite)
    }
    private func drawing() -> PKDrawing {
        let points = [CGPoint(x: 150, y: 100), CGPoint(x: 300, y: 200), CGPoint(x: 450, y: 100)].enumerated().map { index, point in
            PKStrokePoint(location: point, timeOffset: Double(index) * 0.1, size: CGSize(width: 4, height: 4), opacity: 1, force: 1, azimuth: 0, altitude: .pi / 2)
        }
        let path = PKStrokePath(controlPoints: points, creationDate: .now)
        return PKDrawing(strokes: [PKStroke(ink: PKInk(.pencil, color: .black), path: path)])
    }
    func testCurriculumAndBundledReferencesAreComplete() {
        XCTAssertEqual(DrawingLesson.all.map(\.id), Array(1...100))
        XCTAssertEqual(Set(DrawingLesson.all.map(\.title)).count, 100)
        XCTAssertEqual(DrawingLesson.chapters.count, 12)
        for chapter in DrawingLesson.chapters.indices {
            XCTAssertEqual(DrawingLesson.all.filter { $0.chapter == chapter }.count, chapter < 4 ? 5 : 10)
        }
        XCTAssertEqual(Set(StudyReference.all.map(\.id)).count, 100)
        XCTAssertEqual(LessonWorkshop.all.count, 100)
        var imageDigests = Set<String>()
        for reference in StudyReference.all {
            XCTAssertNotNil(UIImage(named: reference.imageName), "Missing offline artwork: \(reference.id)")
            XCTAssertEqual(reference.lessons.count, 1)
            if let url = Bundle.main.url(forResource: reference.imageName, withExtension: nil), let data = try? Data(contentsOf: url) {
                imageDigests.insert(SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined())
            }
        }
        XCTAssertEqual(imageDigests.count, 100, "Every lesson must have its own distinct bundled reference")
        for lesson in DrawingLesson.all {
            XCTAssertNotNil(lesson.workshop, "Missing full workshop for lesson \(lesson.id)")
            XCTAssertGreaterThanOrEqual(lesson.readingWordCount, 330, "Lesson \(lesson.id) must have a developed reading and assignment")
            XCTAssertEqual(Int(lesson.reference.id), lesson.id)
            XCTAssertEqual(lesson.steps.count, 3)
            XCTAssertFalse(lesson.idea.isEmpty || lesson.observation.isEmpty || lesson.check.isEmpty || lesson.transfer.isEmpty)
        }
    }
    func testStudyAndBookmarkSurviveStoreRecreation() throws {
        let store = LearningStore(directory: folder, defaults: defaults)
        store.toggleBookmark(3)
        try store.save(drawing(), lessonID: 1, reflection: "Follow the whole line", complete: true)
        let reopened = LearningStore(directory: folder, defaults: defaults)
        XCTAssertEqual(reopened.completedCount, 1)
        XCTAssertEqual(reopened.nextLesson.id, 2)
        XCTAssertTrue(reopened.progress.bookmarks.contains(3))
        XCTAssertEqual(reopened.progress.studies[1]?.reflection, "Follow the whole line")
        XCTAssertEqual(try reopened.drawing(for: 1).strokes.count, 1)
        XCTAssertEqual(try reopened.drawing(for: 1).bounds.minX, drawing().bounds.minX, accuracy: 0.01)
    }
    func testPersonalPhotoAndReferenceChoiceSurviveRecreation() throws {
        let store = LearningStore(directory: folder, defaults: defaults)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 60)).image { _ in
            UIColor.red.setFill(); UIRectFill(CGRect(x: 0, y: 0, width: 40, height: 60))
        }
        try store.savePersonalReference(image, for: 100)
        store.setReferenceChoice(2, for: 100)
        try store.save(drawing(), lessonID: 100, reflection: "My own reference", complete: true)
        let reopened = LearningStore(directory: folder, defaults: defaults)
        XCTAssertEqual(reopened.referenceChoice(for: 100), 2)
        XCTAssertEqual(reopened.personalReference(for: 100)?.cgImage?.width, image.cgImage?.width)
        XCTAssertEqual(reopened.personalReference(for: 100)?.cgImage?.height, image.cgImage?.height)
        XCTAssertEqual(try reopened.drawing(for: 100).strokes.count, 1)
        XCTAssertEqual(reopened.progress.studies[100]?.reflection, "My own reference")
        XCTAssertEqual(reopened.referenceChoice(for: 1), 0)
        XCTAssertEqual(reopened.referenceChoice(for: 21), 1)
    }

    func testEmptyDrawingCannotCompleteLesson() throws {
        let store = LearningStore(directory: folder, defaults: defaults)
        XCTAssertThrowsError(try store.save(PKDrawing(), lessonID: 1, reflection: "", complete: true))
        XCTAssertEqual(store.completedCount, 0)
        XCTAssertNil(store.progress.studies[1])
    }
    func testRevisitingCompletedStudyKeepsCompletionDate() throws {
        let store = LearningStore(directory: folder, defaults: defaults)
        try store.save(drawing(), lessonID: 1, reflection: "First", complete: true)
        let completedAt = store.progress.studies[1]?.completedAt
        try store.save(drawing(), lessonID: 1, reflection: "Revised")
        XCTAssertEqual(store.progress.studies[1]?.completedAt, completedAt)
        XCTAssertEqual(store.completedCount, 1)
        XCTAssertEqual(store.progress.studies[1]?.reflection, "Revised")
    }
    func testFailedDrawingWriteDoesNotAwardProgress() throws {
        try Data("not a directory".utf8).write(to: folder)
        let store = LearningStore(directory: folder, defaults: defaults)
        XCTAssertThrowsError(try store.save(drawing(), lessonID: 1, reflection: "", complete: true))
        XCTAssertEqual(store.completedCount, 0)
        XCTAssertTrue(store.progress.studies.isEmpty)
    }
    func testCorruptDrawingIsReportedAndPreserved() throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("lesson-1.drawing")
        let corrupt = Data("invalid PencilKit data".utf8)
        try corrupt.write(to: url)
        let store = LearningStore(directory: folder, defaults: defaults)
        XCTAssertThrowsError(try store.drawing(for: 1))
        XCTAssertEqual(try Data(contentsOf: url), corrupt)
    }
    func testResizeKeepsDrawingInCanonicalCoordinates() throws {
        let canvas = StudyCanvas(frame: CGRect(x: 0, y: 0, width: 360, height: 270))
        canvas.load(drawing())
        // Saving before the first layout must also preserve the drawing's scale.
        XCTAssertEqual(canvas.canonicalDrawing.bounds.minX, drawing().bounds.minX, accuracy: 0.1)
        canvas.layoutIfNeeded()
        let before = canvas.canonicalDrawing.bounds
        canvas.frame = CGRect(x: 0, y: 0, width: 800, height: 600)
        canvas.setNeedsLayout(); canvas.layoutIfNeeded()
        let after = canvas.canonicalDrawing.bounds
        XCTAssertEqual(after.minX, before.minX, accuracy: 0.1)
        XCTAssertEqual(after.minY, before.minY, accuracy: 0.1)
        XCTAssertEqual(after.width, before.width, accuracy: 0.1)
        XCTAssertEqual(after.height, before.height, accuracy: 0.1)
    }
}
