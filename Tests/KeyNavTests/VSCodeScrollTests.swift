// Tests/KeyNavTests/VSCodeScrollTests.swift
import XCTest
@testable import KeyNav

final class VSCodeScrollTests: XCTestCase {

    // MARK: - VS Code Scroll Value Limits

    func testScrollLimitsDefaultValues() {
        let limits = ScrollValueLimits()

        // Default should use Int16.max for VS Code compatibility
        XCTAssertEqual(limits.maxScrollUp, Int(Int16.max))
        XCTAssertEqual(limits.maxScrollDown, Int(Int16.max))
    }

    func testScrollLimitsInt16Range() {
        let limits = ScrollValueLimits()

        // Values should be within Int16 range for VS Code compatibility
        XCTAssertLessThanOrEqual(limits.maxScrollUp, Int(Int16.max))
        XCTAssertLessThanOrEqual(limits.maxScrollDown, Int(Int16.max))
    }

    func testCustomScrollLimits() {
        let limits = ScrollValueLimits(maxScrollUp: 1000, maxScrollDown: 2000)

        XCTAssertEqual(limits.maxScrollUp, 1000)
        XCTAssertEqual(limits.maxScrollDown, 2000)
    }

    // MARK: - Clamp Values

    func testClampScrollValueWithinLimits() {
        let limits = ScrollValueLimits()

        // Values within limits should pass through
        XCTAssertEqual(limits.clampScrollUp(100), 100)
        XCTAssertEqual(limits.clampScrollDown(100), 100)
    }

    func testClampScrollValueExceedingLimits() {
        let limits = ScrollValueLimits()

        // Values exceeding Int16.max should be clamped
        XCTAssertEqual(limits.clampScrollUp(Int(Int32.max)), Int(Int16.max))
        XCTAssertEqual(limits.clampScrollDown(Int(Int32.max)), Int(Int16.max))
    }

    func testClampScrollValueNegative() {
        let limits = ScrollValueLimits()

        // Negative values should be clamped to negative max
        XCTAssertEqual(limits.clampScrollUp(-Int(Int16.max) - 1000), -Int(Int16.max))
    }

    // MARK: - VS Code Specific Bug Workaround

    func testVSCodeCompatibilityDocumentation() {
        // This test documents the VS Code bug:
        // When using Int32.max for upward scrolling, VS Code
        // incorrectly scrolls to the bottom instead of the top.
        // Using Int16.max works correctly.

        let limits = ScrollValueLimits()

        // Verify we're using the safe value
        XCTAssertEqual(limits.maxScrollUp, Int(Int16.max),
                      "Must use Int16.max for VS Code compatibility")

        // Int16.max = 32767
        XCTAssertEqual(limits.maxScrollUp, 32767)
    }
}
