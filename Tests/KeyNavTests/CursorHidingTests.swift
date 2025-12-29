// Tests/KeyNavTests/CursorHidingTests.swift
import XCTest
@testable import KeyNav

final class CursorHidingTests: XCTestCase {

    // MARK: - Cursor Manager Tests

    func testCursorManagerStartsWithVisibleCursor() {
        let manager = CursorManager()
        XCTAssertTrue(manager.isCursorVisible)
    }

    func testHideCursorSetsCursorInvisible() {
        let manager = CursorManager()
        manager.hideCursor()
        XCTAssertFalse(manager.isCursorVisible)
    }

    func testShowCursorSetsCursorVisible() {
        let manager = CursorManager()
        manager.hideCursor()
        manager.showCursor()
        XCTAssertTrue(manager.isCursorVisible)
    }

    func testMultipleHideCallsAreIdempotent() {
        let manager = CursorManager()
        manager.hideCursor()
        manager.hideCursor()
        manager.hideCursor()
        XCTAssertFalse(manager.isCursorVisible)
        // One show should restore
        manager.showCursor()
        XCTAssertTrue(manager.isCursorVisible)
    }

    func testMultipleShowCallsAreIdempotent() {
        let manager = CursorManager()
        manager.showCursor()
        manager.showCursor()
        XCTAssertTrue(manager.isCursorVisible)
    }

    func testHideShowSequenceMaintainsState() {
        let manager = CursorManager()

        manager.hideCursor()
        XCTAssertFalse(manager.isCursorVisible)

        manager.showCursor()
        XCTAssertTrue(manager.isCursorVisible)

        manager.hideCursor()
        XCTAssertFalse(manager.isCursorVisible)

        manager.showCursor()
        XCTAssertTrue(manager.isCursorVisible)
    }
}
