// Tests/KeyNavTests/ReverseScrollTests.swift
import XCTest
@testable import KeyNav

final class ReverseScrollTests: XCTestCase {

    // MARK: - Default (Non-Reversed) Scroll

    func testDefaultScrollDirections() {
        let logic = ScrollModeLogic()

        // J scrolls down (negative Y)
        let jResult = logic.handleKeyCode(0, characters: "j", modifiers: [])
        if case .scroll(_, let deltaY) = jResult {
            XCTAssertLessThan(deltaY, 0, "J should scroll down (negative Y)")
        } else {
            XCTFail("Expected scroll result")
        }

        // K scrolls up (positive Y)
        let kResult = logic.handleKeyCode(0, characters: "k", modifiers: [])
        if case .scroll(_, let deltaY) = kResult {
            XCTAssertGreaterThan(deltaY, 0, "K should scroll up (positive Y)")
        } else {
            XCTFail("Expected scroll result")
        }

        // H scrolls left (positive X)
        let hResult = logic.handleKeyCode(0, characters: "h", modifiers: [])
        if case .scroll(let deltaX, _) = hResult {
            XCTAssertGreaterThan(deltaX, 0, "H should scroll left (positive X)")
        } else {
            XCTFail("Expected scroll result")
        }

        // L scrolls right (negative X)
        let lResult = logic.handleKeyCode(0, characters: "l", modifiers: [])
        if case .scroll(let deltaX, _) = lResult {
            XCTAssertLessThan(deltaX, 0, "L should scroll right (negative X)")
        } else {
            XCTFail("Expected scroll result")
        }
    }

    // MARK: - Reversed Vertical Scroll

    func testReversedVerticalScroll() {
        let logic = ScrollModeLogic(reverseVertical: true)

        // J should now scroll up (positive Y) when reversed
        let jResult = logic.handleKeyCode(0, characters: "j", modifiers: [])
        if case .scroll(_, let deltaY) = jResult {
            XCTAssertGreaterThan(deltaY, 0, "J with reversed vertical should scroll up")
        } else {
            XCTFail("Expected scroll result")
        }

        // K should now scroll down (negative Y) when reversed
        let kResult = logic.handleKeyCode(0, characters: "k", modifiers: [])
        if case .scroll(_, let deltaY) = kResult {
            XCTAssertLessThan(deltaY, 0, "K with reversed vertical should scroll down")
        } else {
            XCTFail("Expected scroll result")
        }
    }

    // MARK: - Reversed Horizontal Scroll

    func testReversedHorizontalScroll() {
        let logic = ScrollModeLogic(reverseHorizontal: true)

        // H should now scroll right (negative X) when reversed
        let hResult = logic.handleKeyCode(0, characters: "h", modifiers: [])
        if case .scroll(let deltaX, _) = hResult {
            XCTAssertLessThan(deltaX, 0, "H with reversed horizontal should scroll right")
        } else {
            XCTFail("Expected scroll result")
        }

        // L should now scroll left (positive X) when reversed
        let lResult = logic.handleKeyCode(0, characters: "l", modifiers: [])
        if case .scroll(let deltaX, _) = lResult {
            XCTAssertGreaterThan(deltaX, 0, "L with reversed horizontal should scroll left")
        } else {
            XCTFail("Expected scroll result")
        }
    }

    // MARK: - Both Directions Reversed

    func testBothDirectionsReversed() {
        let logic = ScrollModeLogic(reverseHorizontal: true, reverseVertical: true)

        // All directions should be reversed
        let jResult = logic.handleKeyCode(0, characters: "j", modifiers: [])
        if case .scroll(_, let deltaY) = jResult {
            XCTAssertGreaterThan(deltaY, 0, "J should be reversed")
        } else {
            XCTFail("Expected scroll result")
        }

        let hResult = logic.handleKeyCode(0, characters: "h", modifiers: [])
        if case .scroll(let deltaX, _) = hResult {
            XCTAssertLessThan(deltaX, 0, "H should be reversed")
        } else {
            XCTFail("Expected scroll result")
        }
    }

    // MARK: - Half-Page Scroll Also Reverses

    func testReversedHalfPageScroll() {
        let logic = ScrollModeLogic(reverseVertical: true)

        // D (half-page down) should now go up when vertical is reversed
        let dResult = logic.handleKeyCode(0, characters: "d", modifiers: [])
        if case .scroll(_, let deltaY) = dResult {
            XCTAssertGreaterThan(deltaY, 0, "D with reversed vertical should scroll up")
        } else {
            XCTFail("Expected scroll result")
        }

        // U (half-page up) should now go down when vertical is reversed
        let uResult = logic.handleKeyCode(0, characters: "u", modifiers: [])
        if case .scroll(_, let deltaY) = uResult {
            XCTAssertLessThan(deltaY, 0, "U with reversed vertical should scroll down")
        } else {
            XCTFail("Expected scroll result")
        }
    }
}
