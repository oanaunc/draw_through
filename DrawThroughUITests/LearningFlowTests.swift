import XCTest

final class LearningFlowTests: XCTestCase {
    override func setUp() { continueAfterFailure = false }
    @MainActor func testPracticeSaveAndReturnThroughJournal() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-hasSeenOnboarding", "YES"]
        app.launch()
        XCTAssertTrue(app.buttons["Learn"].firstMatch.waitForExistence(timeout: 15))
        attach("01-Learn")
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Begin study")).firstMatch.tap()
        XCTAssertTrue(app.buttons["Open practice pad"].waitForExistence(timeout: 5) || app.buttons["Continue practice"].exists)
        attach("02-Lesson")
        let open = app.buttons["Open practice pad"].exists ? app.buttons["Open practice pad"] : app.buttons["Continue practice"]
        open.tap()
        let surface = app.scrollViews["practiceSurface"]
        XCTAssertTrue(surface.waitForExistence(timeout: 5))
        let start = surface.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.25))
        let end = surface.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.65))
        start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertTrue(app.buttons["Undo stroke"].isEnabled)
        app.buttons["Undo stroke"].tap()
        XCTAssertTrue(app.buttons["Redo stroke"].isEnabled)
        app.buttons["Redo stroke"].tap()
        XCTAssertTrue(app.buttons["Clear"].isEnabled)
        app.segmentedControls.buttons["Faint"].tap()
        app.segmentedControls.buttons["Freehand"].tap()
        attach("03-Practice")
        let reflection = app.descendants(matching: .any).matching(identifier: "studyReflection").firstMatch
        app.staticTexts["Look back at your study"].swipeUp()
        XCTAssertTrue(reflection.waitForExistence(timeout: 5))
        reflection.tap(); reflection.typeText("I followed the whole line.")
        app.buttons["Done"].tap()
        let complete = app.buttons["Complete study"]
        app.staticTexts["Look back at your study"].swipeUp()
        XCTAssertTrue(complete.waitForExistence(timeout: 5))
        XCTAssertTrue(complete.isEnabled)
        complete.tap()
        XCTAssertTrue(app.buttons["Continue practice"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["My practice"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Studied · tap to revisit"].waitForExistence(timeout: 5))
        attach("04-Journal")
        app.terminate(); app.launch()
        app.buttons["My practice"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Studied · tap to revisit"].waitForExistence(timeout: 5))
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Studied · tap to revisit")).firstMatch.tap()
        app.buttons["Continue practice"].tap()
        XCTAssertTrue(app.buttons["Clear"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Clear"].isEnabled)
        app.buttons["Close"].tap()
    }
    @MainActor func testSearchAndStudioRemainAccessible() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-hasSeenOnboarding", "YES"]
        app.launch()
        let search = app.textFields["lessonSearch"]
        app.swipeUp()
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap(); search.typeText("perspective")
        app.keyboards.buttons["Search"].tap()
        XCTAssertTrue(app.staticTexts["A room in perspective"].waitForExistence(timeout: 5))
        app.buttons["Studio"].firstMatch.tap()
        XCTAssertTrue(app.buttons["New Canvas"].waitForExistence(timeout: 5))
        app.buttons["New Canvas"].tap()
        XCTAssertTrue(app.navigationBars["New Canvas"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
    }
    @MainActor func testOnboardingAndSavedLessons() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-hasSeenOnboarding", "NO"]
        app.launch()
        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 10))
        app.buttons["Continue"].tap(); app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Enter the studio"].exists)
        // A forced UserDefaults launch argument overrides writes; relaunch without that override.
        app.terminate()
        app.launchArguments = ["-hasSeenOnboarding", "YES"]
        app.launch()
        XCTAssertTrue(app.buttons["Learn"].firstMatch.waitForExistence(timeout: 5))
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Begin study")).firstMatch.tap()
        let bookmark = app.buttons["Save lesson"]
        if bookmark.exists { bookmark.tap() }
        XCTAssertTrue(app.buttons["Unsave lesson"].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.swipeUp()
        app.descendants(matching: .any).matching(identifier: "savedLessonsFilter").firstMatch.tap()
        XCTAssertFalse(app.staticTexts["No lessons found"].exists)
        app.buttons["Studio"].firstMatch.tap()
        XCTAssertTrue(app.buttons["New Canvas"].exists)
    }

    @MainActor private func attach(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways
        add(attachment)
    }
}
