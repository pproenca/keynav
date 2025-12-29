// Tests/KeyNavTests/FullscreenWindowTests.swift
import XCTest
@testable import KeyNav

final class FullscreenWindowTests: XCTestCase {

    // MARK: - Screen Detection

    func testFindScreenByIntersection() {
        let detector = ScreenDetector()

        // Window fully on primary screen
        let windowFrame = CGRect(x: 100, y: 100, width: 800, height: 600)
        let primaryScreen = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let secondaryScreen = CGRect(x: 1920, y: 0, width: 1920, height: 1080)

        let result = detector.findScreen(
            for: windowFrame,
            screens: [primaryScreen, secondaryScreen]
        )

        XCTAssertEqual(result, primaryScreen)
    }

    func testFindScreenForSecondaryDisplay() {
        let detector = ScreenDetector()

        // Window on secondary display
        let windowFrame = CGRect(x: 2000, y: 100, width: 800, height: 600)
        let primaryScreen = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let secondaryScreen = CGRect(x: 1920, y: 0, width: 1920, height: 1080)

        let result = detector.findScreen(
            for: windowFrame,
            screens: [primaryScreen, secondaryScreen]
        )

        XCTAssertEqual(result, secondaryScreen)
    }

    func testFindScreenForSpanningWindow() {
        let detector = ScreenDetector()

        // Window spanning both screens - should return screen with larger intersection
        let windowFrame = CGRect(x: 1800, y: 100, width: 800, height: 600)  // 120px on primary, 680px on secondary
        let primaryScreen = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let secondaryScreen = CGRect(x: 1920, y: 0, width: 1920, height: 1080)

        let result = detector.findScreen(
            for: windowFrame,
            screens: [primaryScreen, secondaryScreen]
        )

        // Secondary has larger intersection area
        XCTAssertEqual(result, secondaryScreen)
    }

    // MARK: - Intersection Area Calculation

    func testIntersectionAreaCalculation() {
        let detector = ScreenDetector()

        let rect1 = CGRect(x: 0, y: 0, width: 100, height: 100)
        let rect2 = CGRect(x: 50, y: 50, width: 100, height: 100)

        let intersection = detector.intersectionArea(rect1, rect2)

        // 50x50 overlap
        XCTAssertEqual(intersection, 2500)
    }

    func testNoIntersectionReturnsZero() {
        let detector = ScreenDetector()

        let rect1 = CGRect(x: 0, y: 0, width: 100, height: 100)
        let rect2 = CGRect(x: 200, y: 200, width: 100, height: 100)

        let intersection = detector.intersectionArea(rect1, rect2)

        XCTAssertEqual(intersection, 0)
    }

    // MARK: - Fullscreen Detection

    func testFullscreenWindowDetection() {
        let detector = ScreenDetector()

        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let fullscreenWindow = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let normalWindow = CGRect(x: 100, y: 100, width: 800, height: 600)

        XCTAssertTrue(detector.isFullscreen(fullscreenWindow, on: screenFrame))
        XCTAssertFalse(detector.isFullscreen(normalWindow, on: screenFrame))
    }

    func testNearFullscreenDetection() {
        let detector = ScreenDetector()

        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        // Window slightly smaller than screen (menu bar)
        let almostFullscreen = CGRect(x: 0, y: 25, width: 1920, height: 1055)

        // Should still be considered fullscreen (within tolerance)
        XCTAssertTrue(detector.isFullscreen(almostFullscreen, on: screenFrame, tolerance: 0.05))
    }

    // MARK: - Edge Cases

    func testEmptyScreensList() {
        let detector = ScreenDetector()

        let windowFrame = CGRect(x: 100, y: 100, width: 800, height: 600)

        let result = detector.findScreen(for: windowFrame, screens: [])

        XCTAssertNil(result)
    }
}
