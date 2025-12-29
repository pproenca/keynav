// Tests/KeyNavTests/HintModeModifierTests.swift
import XCTest
@testable import KeyNav

/// Tests for modifier key handling in HintMode
/// - Shift + hint key → right-click
/// - Command + hint key → double-click
/// - Option + hint key → move mouse only (no click)
/// - No modifier → left-click (default)
final class HintModeModifierTests: XCTestCase {

    var logic: HintModeLogic!

    override func setUp() {
        super.setUp()
        logic = HintModeLogic()
        logic.setElements([
            ActionableElement(role: "AXButton", label: "Save", frame: CGRect(x: 0, y: 0, width: 100, height: 30), actions: ["AXPress"], identifier: "save-btn"),
            ActionableElement(role: "AXButton", label: "Cancel", frame: CGRect(x: 100, y: 0, width: 100, height: 30), actions: ["AXPress"], identifier: "cancel-btn"),
        ])
    }

    override func tearDown() {
        logic = nil
        super.tearDown()
    }

    // MARK: - Click Type Tests

    func testSelectWithNoModifierReturnsLeftClick() {
        // Press 'A' with no modifiers - should return left-click action
        let result = logic.handleKeyCode(0, characters: "a", modifiers: [])

        if case .selectElement(let element, let clickType) = result {
            XCTAssertEqual(element.label, "Save")
            XCTAssertEqual(clickType, .leftClick)
        } else {
            XCTFail("Expected selectElement result with leftClick, got \(result)")
        }
    }

    func testSelectWithShiftReturnsRightClick() {
        // Press Shift+A - should return right-click action
        let result = logic.handleKeyCode(0, characters: "a", modifiers: [.shift])

        if case .selectElement(let element, let clickType) = result {
            XCTAssertEqual(element.label, "Save")
            XCTAssertEqual(clickType, .rightClick)
        } else {
            XCTFail("Expected selectElement result with rightClick, got \(result)")
        }
    }

    func testSelectWithCommandReturnsDoubleClick() {
        // Press Command+A - should return double-click action
        let result = logic.handleKeyCode(0, characters: "a", modifiers: [.command])

        if case .selectElement(let element, let clickType) = result {
            XCTAssertEqual(element.label, "Save")
            XCTAssertEqual(clickType, .doubleClick)
        } else {
            XCTFail("Expected selectElement result with doubleClick, got \(result)")
        }
    }

    func testSelectWithOptionReturnsMoveOnly() {
        // Press Option+A - should return move-only action (no click)
        let result = logic.handleKeyCode(0, characters: "a", modifiers: [.option])

        if case .selectElement(let element, let clickType) = result {
            XCTAssertEqual(element.label, "Save")
            XCTAssertEqual(clickType, .moveOnly)
        } else {
            XCTFail("Expected selectElement result with moveOnly, got \(result)")
        }
    }

    func testSelectWithControlUsesLeftClick() {
        // Press Control+A - Control doesn't change click type, still left-click
        let result = logic.handleKeyCode(0, characters: "a", modifiers: [.control])

        if case .selectElement(let element, let clickType) = result {
            XCTAssertEqual(element.label, "Save")
            XCTAssertEqual(clickType, .leftClick)
        } else {
            XCTFail("Expected selectElement result with leftClick, got \(result)")
        }
    }

    // MARK: - Combined Modifier Tests

    func testShiftTakesPrecedenceOverCommand() {
        // When both Shift and Command are held, Shift (right-click) takes precedence
        let result = logic.handleKeyCode(0, characters: "a", modifiers: [.shift, .command])

        if case .selectElement(_, let clickType) = result {
            XCTAssertEqual(clickType, .rightClick, "Shift should take precedence for right-click")
        } else {
            XCTFail("Expected selectElement result")
        }
    }

    // MARK: - Backward Compatibility

    func testHandleKeyCodeWithoutModifiersDefaultsToLeftClick() {
        // The old API without modifiers should still work and default to left-click
        let result = logic.handleKeyCode(0, characters: "a")

        if case .selectElement(let element, let clickType) = result {
            XCTAssertEqual(element.label, "Save")
            XCTAssertEqual(clickType, .leftClick)
        } else {
            XCTFail("Expected selectElement result with leftClick, got \(result)")
        }
    }
}
