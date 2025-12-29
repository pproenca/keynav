// Tests/KeyNavTests/WindowBoundaryTests.swift
import XCTest
@testable import KeyNav

final class WindowBoundaryTests: XCTestCase {

    // MARK: - Window Extends Beyond Screen

    func testWindowExtendsLeftOfScreen() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: -100, y: 0, width: 800, height: 600)
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let clipped = handler.clipToScreen(window, screen: screen)

        XCTAssertEqual(clipped.minX, 0)
        XCTAssertEqual(clipped.width, 700)  // 800 - 100 clipped off
    }

    func testWindowExtendsRightOfScreen() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: 1500, y: 0, width: 800, height: 600)
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let clipped = handler.clipToScreen(window, screen: screen)

        XCTAssertEqual(clipped.maxX, 1920)
        XCTAssertEqual(clipped.width, 420)  // 1920 - 1500
    }

    func testWindowExtendsAboveScreen() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: 0, y: -50, width: 800, height: 600)
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let clipped = handler.clipToScreen(window, screen: screen)

        XCTAssertEqual(clipped.minY, 0)
        XCTAssertEqual(clipped.height, 550)  // 600 - 50 clipped off
    }

    func testWindowExtendsBelowScreen() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: 0, y: 700, width: 800, height: 600)
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let clipped = handler.clipToScreen(window, screen: screen)

        XCTAssertEqual(clipped.maxY, 1080)
        XCTAssertEqual(clipped.height, 380)  // 1080 - 700
    }

    // MARK: - Window Within Bounds

    func testWindowFullyWithinScreen() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: 100, y: 100, width: 800, height: 600)
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let clipped = handler.clipToScreen(window, screen: screen)

        XCTAssertEqual(clipped, window)
    }

    // MARK: - Window Completely Outside Screen

    func testWindowCompletelyOutsideScreen() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: 3000, y: 0, width: 800, height: 600)
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let clipped = handler.clipToScreen(window, screen: screen)

        XCTAssertTrue(clipped.isEmpty)
    }

    // MARK: - Visible Portion Calculation

    func testVisiblePortionPercentage() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: -400, y: 0, width: 800, height: 600)  // Half off-screen
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let percentage = handler.visiblePercentage(of: window, on: screen)

        XCTAssertEqual(percentage, 0.5, accuracy: 0.01)
    }

    func testFullyVisiblePercentage() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: 100, y: 100, width: 800, height: 600)
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let percentage = handler.visiblePercentage(of: window, on: screen)

        XCTAssertEqual(percentage, 1.0, accuracy: 0.01)
    }

    func testNotVisiblePercentage() {
        let handler = WindowBoundaryHandler()

        let window = CGRect(x: 3000, y: 0, width: 800, height: 600)
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        let percentage = handler.visiblePercentage(of: window, on: screen)

        XCTAssertEqual(percentage, 0.0, accuracy: 0.01)
    }
}
