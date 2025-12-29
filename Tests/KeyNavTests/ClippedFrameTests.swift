// Tests/KeyNavTests/ClippedFrameTests.swift
import XCTest
@testable import KeyNav

final class ClippedFrameTests: XCTestCase {

    // MARK: - Clipped Frame Calculation

    func testElementFullyVisibleInViewport() {
        let calculator = ClippedFrameCalculator()

        let element = CGRect(x: 100, y: 100, width: 200, height: 50)
        let viewport = CGRect(x: 0, y: 0, width: 800, height: 600)

        let clipped = calculator.visibleFrame(of: element, in: viewport)

        XCTAssertEqual(clipped, element)
    }

    func testElementPartiallyClippedTop() {
        let calculator = ClippedFrameCalculator()

        let element = CGRect(x: 100, y: -25, width: 200, height: 50)
        let viewport = CGRect(x: 0, y: 0, width: 800, height: 600)

        let clipped = calculator.visibleFrame(of: element, in: viewport)

        XCTAssertEqual(clipped.minY, 0)
        XCTAssertEqual(clipped.height, 25)
    }

    func testElementPartiallyClippedBottom() {
        let calculator = ClippedFrameCalculator()

        let element = CGRect(x: 100, y: 575, width: 200, height: 50)
        let viewport = CGRect(x: 0, y: 0, width: 800, height: 600)

        let clipped = calculator.visibleFrame(of: element, in: viewport)

        XCTAssertEqual(clipped.maxY, 600)
        XCTAssertEqual(clipped.height, 25)
    }

    func testElementCompletelyOutsideViewport() {
        let calculator = ClippedFrameCalculator()

        let element = CGRect(x: 1000, y: 100, width: 200, height: 50)
        let viewport = CGRect(x: 0, y: 0, width: 800, height: 600)

        let clipped = calculator.visibleFrame(of: element, in: viewport)

        XCTAssertTrue(clipped.isEmpty)
    }

    // MARK: - Visibility Check

    func testElementIsVisible() {
        let calculator = ClippedFrameCalculator()

        let visibleElement = CGRect(x: 100, y: 100, width: 200, height: 50)
        let hiddenElement = CGRect(x: 1000, y: 100, width: 200, height: 50)
        let viewport = CGRect(x: 0, y: 0, width: 800, height: 600)

        XCTAssertTrue(calculator.isVisible(visibleElement, in: viewport))
        XCTAssertFalse(calculator.isVisible(hiddenElement, in: viewport))
    }

    // MARK: - Minimum Visible Area

    func testMinimumVisibleAreaThreshold() {
        let calculator = ClippedFrameCalculator()

        // Element with only 2x50 visible (100 sq px) - at threshold
        // x: -198 means only 2px visible horizontally
        let tinyVisible = CGRect(x: -198, y: 100, width: 200, height: 50)
        let viewport = CGRect(x: 0, y: 0, width: 800, height: 600)

        // 2 * 50 = 100 which equals minArea, so should be visible
        // Test with higher threshold to make it fail
        XCTAssertFalse(calculator.isMeaningfullyVisible(tinyVisible, in: viewport, minArea: 150))
    }

    func testAboveMinimumVisibleAreaThreshold() {
        let calculator = ClippedFrameCalculator()

        let element = CGRect(x: 100, y: 100, width: 200, height: 50)
        let viewport = CGRect(x: 0, y: 0, width: 800, height: 600)

        XCTAssertTrue(calculator.isMeaningfullyVisible(element, in: viewport, minArea: 100))
    }

    // MARK: - Nested Viewports

    func testNestedViewportClipping() {
        let calculator = ClippedFrameCalculator()

        let element = CGRect(x: 50, y: 50, width: 100, height: 100)
        let innerViewport = CGRect(x: 0, y: 0, width: 200, height: 200)
        let outerViewport = CGRect(x: 100, y: 100, width: 400, height: 400)

        // First clip to inner viewport (element is fully within)
        let clipped1 = calculator.visibleFrame(of: element, in: innerViewport)
        XCTAssertEqual(clipped1, element)

        // Then translate and clip to outer viewport
        let translatedElement = CGRect(x: 150, y: 150, width: 100, height: 100)
        let clipped2 = calculator.visibleFrame(of: translatedElement, in: outerViewport)
        XCTAssertEqual(clipped2, translatedElement)
    }
}
