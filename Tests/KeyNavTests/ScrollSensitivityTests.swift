// Tests/KeyNavTests/ScrollSensitivityTests.swift
import XCTest
@testable import KeyNav

final class ScrollSensitivityTests: XCTestCase {

    // MARK: - Scroll Sensitivity Configuration

    func testDefaultScrollSensitivity() {
        let config = ScrollSensitivityConfig()

        XCTAssertEqual(config.sensitivity, 20)
        // At 20%: small = 10 + (200-10)*0.2 = 48
        XCTAssertEqual(config.smallScrollAmount, 48)
        // At 20%: page = 60 + (600-60)*0.2 = 168
        XCTAssertEqual(config.pageScrollAmount, 168)
    }

    func testMinimumScrollSensitivity() {
        let config = ScrollSensitivityConfig(sensitivity: 0)

        XCTAssertEqual(config.sensitivity, 0)
        XCTAssertEqual(config.smallScrollAmount, 10)  // Minimum
        XCTAssertEqual(config.pageScrollAmount, 60)   // Minimum
    }

    func testMaximumScrollSensitivity() {
        let config = ScrollSensitivityConfig(sensitivity: 100)

        XCTAssertEqual(config.sensitivity, 100)
        XCTAssertEqual(config.smallScrollAmount, 200) // Maximum
        XCTAssertEqual(config.pageScrollAmount, 600)  // Maximum
    }

    func testMidRangeScrollSensitivity() {
        let config = ScrollSensitivityConfig(sensitivity: 50)

        XCTAssertEqual(config.sensitivity, 50)
        // At 50%: small = 10 + (200-10)*0.5 = 105
        XCTAssertEqual(config.smallScrollAmount, 105)
        // At 50%: page = 60 + (600-60)*0.5 = 330
        XCTAssertEqual(config.pageScrollAmount, 330)
    }

    func testScrollSensitivityClampedToRange() {
        // Values below 0 should clamp to 0
        let configLow = ScrollSensitivityConfig(sensitivity: -10)
        XCTAssertEqual(configLow.sensitivity, 0)

        // Values above 100 should clamp to 100
        let configHigh = ScrollSensitivityConfig(sensitivity: 150)
        XCTAssertEqual(configHigh.sensitivity, 100)
    }

    // MARK: - Integration with ScrollModeLogic

    func testScrollModeLogicWithLowSensitivity() {
        let config = ScrollSensitivityConfig(sensitivity: 0)
        let logic = ScrollModeLogic(
            smallScrollAmount: config.smallScrollAmount,
            pageScrollAmount: config.pageScrollAmount
        )

        let result = logic.handleKeyCode(0, characters: "j", modifiers: [])

        if case .scroll(_, let deltaY) = result {
            XCTAssertEqual(deltaY, -10)  // Minimum scroll
        } else {
            XCTFail("Expected scroll result")
        }
    }

    func testScrollModeLogicWithHighSensitivity() {
        let config = ScrollSensitivityConfig(sensitivity: 100)
        let logic = ScrollModeLogic(
            smallScrollAmount: config.smallScrollAmount,
            pageScrollAmount: config.pageScrollAmount
        )

        let result = logic.handleKeyCode(0, characters: "j", modifiers: [])

        if case .scroll(_, let deltaY) = result {
            XCTAssertEqual(deltaY, -200)  // Maximum scroll
        } else {
            XCTFail("Expected scroll result")
        }
    }
}
