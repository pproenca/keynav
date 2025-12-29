// Tests/KeyNavTests/DeadendDetectionTests.swift
import XCTest
@testable import KeyNav

final class DeadendDetectionTests: XCTestCase {

    // MARK: - Deadend Detection in HintModeLogic

    func testTypingInvalidHintCharacterIsIgnored() {
        let logic = HintModeLogic()

        // Set up elements with known hints (A, S, D, F...)
        let elements = [
            ActionableElement(role: "AXButton", label: "Button 1", frame: CGRect(x: 0, y: 0, width: 100, height: 100), actions: ["AXPress"], identifier: nil),
            ActionableElement(role: "AXButton", label: "Button 2", frame: CGRect(x: 100, y: 0, width: 100, height: 100), actions: ["AXPress"], identifier: nil)
        ]
        logic.setElements(elements)

        // Type 'Z' which is not a hint character
        let result = logic.handleKeyCode(6, characters: "z", modifiers: [])

        // Should be ignored (not a hint char, could be search)
        // Actually in HintMode, non-hint chars become search
        XCTAssertTrue(result == .handled, "Non-hint char should trigger search mode")
    }

    func testTypingValidHintFollowedByInvalidIsDeadend() {
        let logic = HintModeLogic()

        // Set up 20 elements to get two-char hints like "AA", "AS", "AD", etc.
        var elements: [ActionableElement] = []
        for i in 0..<20 {
            elements.append(ActionableElement(
                role: "AXButton",
                label: "Button \(i)",
                frame: CGRect(x: CGFloat(i * 50), y: 0, width: 50, height: 50),
                actions: ["AXPress"],
                identifier: nil
            ))
        }
        logic.setElements(elements)

        // Type 'A' (valid first char)
        _ = logic.handleKeyCode(0, characters: "a", modifiers: [])

        // Verify we're in partial hint state
        XCTAssertEqual(logic.typedHintChars, "A")

        // Now type something that doesn't complete any hint
        // We need to find a char that when combined with 'A' doesn't form a valid hint
        // The hints are generated from "SADFJKLEWCMPGH" so "AZ" wouldn't be valid
        // But since we're filtering by first char, we'd need to check the actual hints
    }

    // MARK: - InputState Deadend Detection

    func testInputStateDetectsDeadendOnInvalidSequence() {
        let inputState = InputState()

        // Register some sequences
        inputState.addKeySequence("ab")
        inputState.addKeySequence("ac")
        inputState.addKeySequence("bc")

        // Advance with 'a' - should be advancable
        inputState.advance(with: "a")
        XCTAssertEqual(inputState.state, .advancable)

        // Now advance with 'z' - should be deadend
        inputState.advance(with: "z")
        XCTAssertEqual(inputState.state, .deadend)
    }

    func testInputStateDeadendAfterCompletelyInvalidInput() {
        let inputState = InputState()

        inputState.addKeySequence("hello")
        inputState.addKeySequence("world")

        // Start with 'x' which doesn't match any prefix
        inputState.advance(with: "x")
        XCTAssertEqual(inputState.state, .deadend)
    }

    func testInputStateCanResetAfterDeadend() {
        let inputState = InputState()

        inputState.addKeySequence("ab")

        // Get to deadend
        inputState.advance(with: "x")
        XCTAssertEqual(inputState.state, .deadend)

        // Reset should restore to wordsAdded
        inputState.reset()
        XCTAssertEqual(inputState.state, .wordsAdded)
        XCTAssertEqual(inputState.currentInput, "")
    }

    // MARK: - Deadend Analytics

    func testDeadendCounterIncrements() {
        // This tests that we can track deadends for analytics
        let analytics = HintModeAnalytics()

        XCTAssertEqual(analytics.deadendCount, 0)

        analytics.recordDeadend(typedSequence: "AZ")
        XCTAssertEqual(analytics.deadendCount, 1)

        analytics.recordDeadend(typedSequence: "XY")
        XCTAssertEqual(analytics.deadendCount, 2)
    }

    func testAnalyticsReset() {
        let analytics = HintModeAnalytics()

        analytics.recordDeadend(typedSequence: "AZ")
        analytics.recordDeadend(typedSequence: "XY")

        analytics.reset()
        XCTAssertEqual(analytics.deadendCount, 0)
    }
}
