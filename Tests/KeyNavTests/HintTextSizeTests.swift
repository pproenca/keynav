// Tests/KeyNavTests/HintTextSizeTests.swift
import XCTest
@testable import KeyNav

final class HintTextSizeTests: XCTestCase {

    // MARK: - Default Configuration

    func testDefaultHintTextSize() {
        let prefs = HintTextSizePrefs()

        XCTAssertEqual(prefs.size, 11.0, accuracy: 0.01)
    }

    // MARK: - Custom Size

    func testCustomHintTextSize() {
        let prefs = HintTextSizePrefs(size: 14.0)

        XCTAssertEqual(prefs.size, 14.0, accuracy: 0.01)
    }

    // MARK: - Validation

    func testValidSizeRange() {
        XCTAssertTrue(HintTextSizePrefs.isValid(1.0))
        XCTAssertTrue(HintTextSizePrefs.isValid(11.0))
        XCTAssertTrue(HintTextSizePrefs.isValid(100.0))
    }

    func testInvalidSizeZero() {
        XCTAssertFalse(HintTextSizePrefs.isValid(0.0))
    }

    func testInvalidSizeNegative() {
        XCTAssertFalse(HintTextSizePrefs.isValid(-5.0))
    }

    func testInvalidSizeAboveMax() {
        XCTAssertFalse(HintTextSizePrefs.isValid(101.0))
        XCTAssertFalse(HintTextSizePrefs.isValid(200.0))
    }

    // MARK: - Clamping

    func testClampTooSmall() {
        let size = HintTextSizePrefs.clamp(0.5)

        XCTAssertEqual(size, 1.0, accuracy: 0.01)
    }

    func testClampTooLarge() {
        let size = HintTextSizePrefs.clamp(150.0)

        XCTAssertEqual(size, 100.0, accuracy: 0.01)
    }

    func testClampValidSize() {
        let size = HintTextSizePrefs.clamp(15.0)

        XCTAssertEqual(size, 15.0, accuracy: 0.01)
    }
}
