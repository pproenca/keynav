// Tests/KeyNavTests/ScrollTimingTests.swift
import XCTest
@testable import KeyNav

final class ScrollTimingTests: XCTestCase {

    // MARK: - Scroll Timing Configuration

    func testDefaultScrollTimingIntervals() {
        let config = ScrollTimingConfig()

        // Smooth scrolling for HJKL: 1/50s = 0.02s
        XCTAssertEqual(config.smoothScrollInterval, 0.02, accuracy: 0.001)
        // Chunky scrolling for D/U: 0.25s
        XCTAssertEqual(config.chunkyScrollInterval, 0.25, accuracy: 0.001)
    }

    func testSmoothScrollIsFasterThanChunky() {
        let config = ScrollTimingConfig()

        XCTAssertLessThan(config.smoothScrollInterval, config.chunkyScrollInterval,
                          "Smooth scroll should be faster (smaller interval) than chunky")
    }

    func testCustomScrollTimingIntervals() {
        let config = ScrollTimingConfig(smoothScrollInterval: 0.03, chunkyScrollInterval: 0.5)

        XCTAssertEqual(config.smoothScrollInterval, 0.03, accuracy: 0.001)
        XCTAssertEqual(config.chunkyScrollInterval, 0.5, accuracy: 0.001)
    }

    // MARK: - Scroll Type Detection

    func testDirectionalKeysUseSmoothScrolling() {
        let config = ScrollTimingConfig()

        XCTAssertEqual(config.interval(for: .directional), config.smoothScrollInterval)
    }

    func testHalfPageKeysUseChunkyScrolling() {
        let config = ScrollTimingConfig()

        XCTAssertEqual(config.interval(for: .halfPage), config.chunkyScrollInterval)
    }

    func testJumpKeysUseNoRepeat() {
        let config = ScrollTimingConfig()

        // Jump to top/bottom (gg/G) should not repeat
        XCTAssertNil(config.interval(for: .jump))
    }

    // MARK: - ScrollType Enum

    func testScrollTypeEquality() {
        XCTAssertEqual(ScrollType.directional, ScrollType.directional)
        XCTAssertEqual(ScrollType.halfPage, ScrollType.halfPage)
        XCTAssertEqual(ScrollType.jump, ScrollType.jump)
        XCTAssertNotEqual(ScrollType.directional, ScrollType.halfPage)
    }
}
