// Tests/KeyNavTests/EventSuppressionTests.swift
import XCTest
@testable import KeyNav

final class EventSuppressionTests: XCTestCase {

    // MARK: - Event Suppression Tests

    /// Verifies that consumed events return true (which signals nil return in CGEvent tap)
    func testConsumedEventReturnsTrue() {
        let logic = HintModeLogic()

        // Set up some elements so hints are available
        let elements = [
            ActionableElement(role: "AXButton", label: "Test", frame: CGRect(x: 0, y: 0, width: 100, height: 100), actions: ["AXPress"], identifier: nil)
        ]
        logic.setElements(elements)

        // Simulate key press - 'A' key (first hint)
        let keyCode: UInt16 = 0  // 'A' key
        let result = logic.handleKeyCode(keyCode, characters: "a", modifiers: [])

        // The event should be consumed (handled), which means CGEvent tap returns nil
        XCTAssertTrue(result.shouldConsume, "Hint key should be consumed to suppress system sounds")
    }

    /// Verifies that events with Command modifier are consumed during hint mode
    func testEventWithCommandModifierIsConsumed() {
        let logic = HintModeLogic()

        let elements = [
            ActionableElement(role: "AXButton", label: "Test", frame: CGRect(x: 0, y: 0, width: 100, height: 100), actions: ["AXPress"], identifier: nil)
        ]
        logic.setElements(elements)

        // Simulate Command+A
        let result = logic.handleKeyCode(0, characters: "a", modifiers: [.command])

        // Command+hint key triggers double-click, which should be consumed
        XCTAssertTrue(result.shouldConsume, "Command+hint key should be consumed")
    }

    /// Verifies that events with Shift modifier are consumed during hint mode
    func testEventWithShiftModifierIsConsumed() {
        let logic = HintModeLogic()

        let elements = [
            ActionableElement(role: "AXButton", label: "Test", frame: CGRect(x: 0, y: 0, width: 100, height: 100), actions: ["AXPress"], identifier: nil)
        ]
        logic.setElements(elements)

        // Simulate Shift+A (right-click)
        let result = logic.handleKeyCode(0, characters: "a", modifiers: [.shift])

        XCTAssertTrue(result.shouldConsume, "Shift+hint key should be consumed")
    }

    /// Verifies that events with Control modifier are consumed during hint mode
    func testEventWithControlModifierIsConsumed() {
        let logic = HintModeLogic()

        let elements = [
            ActionableElement(role: "AXButton", label: "Test", frame: CGRect(x: 0, y: 0, width: 100, height: 100), actions: ["AXPress"], identifier: nil)
        ]
        logic.setElements(elements)

        // Simulate Control+[ (exit)
        let result = logic.handleKeyCode(0x21, characters: "[", modifiers: [.control])

        XCTAssertTrue(result.shouldConsume, "Control+[ should be consumed")
    }

    /// Verifies that escape key is consumed
    func testEscapeKeyIsConsumed() {
        let logic = HintModeLogic()

        let elements = [
            ActionableElement(role: "AXButton", label: "Test", frame: CGRect(x: 0, y: 0, width: 100, height: 100), actions: ["AXPress"], identifier: nil)
        ]
        logic.setElements(elements)

        // Simulate Escape key
        let result = logic.handleKeyCode(53, characters: nil, modifiers: [])

        XCTAssertTrue(result.shouldConsume, "Escape key should be consumed")
    }

    /// Verifies that backspace key is consumed during hint mode
    func testBackspaceIsConsumed() {
        let logic = HintModeLogic()

        let elements = [
            ActionableElement(role: "AXButton", label: "Test", frame: CGRect(x: 0, y: 0, width: 100, height: 100), actions: ["AXPress"], identifier: nil)
        ]
        logic.setElements(elements)

        // Type something first
        _ = logic.handleKeyCode(0, characters: "a", modifiers: [])

        // Simulate Backspace
        let result = logic.handleKeyCode(51, characters: nil, modifiers: [])

        XCTAssertTrue(result.shouldConsume, "Backspace key should be consumed")
    }
}

// MARK: - Helper Extension

extension HintModeLogic.KeyResult {
    /// Returns true if this result indicates the event should be consumed
    var shouldConsume: Bool {
        switch self {
        case .ignored:
            return false
        case .handled, .deactivate, .selectElement:
            return true
        }
    }
}
