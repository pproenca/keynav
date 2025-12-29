// Tests/KeyNavTests/HintModeKeyboardCaptureTests.swift
import XCTest
@testable import KeyNav

/// Tests that HintMode properly uses KeyboardEventCapture to handle global key events
final class HintModeKeyboardCaptureTests: XCTestCase {

    func testHintModeStartsCapturingOnActivate() {
        let mockCapture = MockKeyboardEventCapture()
        let hintMode = HintMode(accessibilityEngine: MockAccessibilityEngine(), keyboardCapture: mockCapture)

        hintMode.activate()

        XCTAssertEqual(mockCapture.startCapturingCallCount, 1)
        XCTAssertTrue(mockCapture.isCapturing)
    }

    func testHintModeStopsCapturingOnDeactivate() {
        let mockCapture = MockKeyboardEventCapture()
        let hintMode = HintMode(accessibilityEngine: MockAccessibilityEngine(), keyboardCapture: mockCapture)
        hintMode.activate()

        hintMode.deactivate()

        XCTAssertEqual(mockCapture.stopCapturingCallCount, 1)
        XCTAssertFalse(mockCapture.isCapturing)
    }

    func testHintModeConsumesHintKeyWhenActive() {
        let mockCapture = MockKeyboardEventCapture()
        let mockEngine = MockAccessibilityEngine()
        mockEngine.mockElements = [
            ActionableElement(axElement: nil, role: "AXButton", label: "Button1", frame: .zero, actions: ["AXPress"], identifier: nil),
            ActionableElement(axElement: nil, role: "AXButton", label: "Button2", frame: .zero, actions: ["AXPress"], identifier: nil),
        ]
        let hintMode = HintMode(accessibilityEngine: mockEngine, keyboardCapture: mockCapture)
        hintMode.activate()

        // Wait for elements to load
        let expectation = XCTestExpectation(description: "Elements loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Simulate pressing 'A' (keyCode 0) - should be consumed as it's a hint key
        let consumed = mockCapture.simulateKeyDown(keyCode: 0, characters: "a")

        XCTAssertTrue(consumed, "Hint key 'A' should be consumed when hint mode is active")
    }

    func testHintModeConsumesEscapeKey() {
        let mockCapture = MockKeyboardEventCapture()
        let hintMode = HintMode(accessibilityEngine: MockAccessibilityEngine(), keyboardCapture: mockCapture)
        hintMode.activate()

        // Simulate pressing Escape (keyCode 53)
        let consumed = mockCapture.simulateKeyDown(keyCode: 53, characters: nil)

        XCTAssertTrue(consumed, "Escape key should be consumed")
        XCTAssertFalse(hintMode.isActive, "HintMode should be deactivated after Escape")
    }

    func testHintModeSelectsElementOnHintMatch() {
        let mockCapture = MockKeyboardEventCapture()
        let mockEngine = MockAccessibilityEngine()
        let delegate = MockHintModeDelegate()

        let element1 = ActionableElement(axElement: nil, role: "AXButton", label: "Button1", frame: .zero, actions: ["AXPress"], identifier: nil)
        let element2 = ActionableElement(axElement: nil, role: "AXButton", label: "Button2", frame: .zero, actions: ["AXPress"], identifier: nil)
        mockEngine.mockElements = [element1, element2]

        let hintMode = HintMode(accessibilityEngine: mockEngine, keyboardCapture: mockCapture)
        hintMode.delegate = delegate
        hintMode.activate()

        // Wait for elements to load
        let expectation = XCTestExpectation(description: "Elements loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Simulate pressing 'A' (keyCode 0) - should select first element (hint "A")
        _ = mockCapture.simulateKeyDown(keyCode: 0, characters: "a")

        XCTAssertTrue(delegate.didSelectElement, "Should have selected an element")
        XCTAssertEqual(delegate.selectedElement?.label, "Button1", "Should have selected the first element")
    }

    func testHintModeDoesNotConsumeKeysWhenInactive() {
        let mockCapture = MockKeyboardEventCapture()
        _ = HintMode(accessibilityEngine: MockAccessibilityEngine(), keyboardCapture: mockCapture)
        // Don't activate - HintMode is not active, so keys should pass through

        // Simulate pressing 'A' - should NOT be consumed since hint mode is not active
        let consumed = mockCapture.simulateKeyDown(keyCode: 0, characters: "a")

        XCTAssertFalse(consumed, "Keys should not be consumed when hint mode is inactive")
    }

    func testHintModeConsumesCtrlLeftBracket() {
        let mockCapture = MockKeyboardEventCapture()
        let hintMode = HintMode(accessibilityEngine: MockAccessibilityEngine(), keyboardCapture: mockCapture)
        hintMode.activate()

        // Simulate pressing Ctrl+[ (keyCode 33 with control modifier) - Vim-style escape
        let consumed = mockCapture.simulateKeyDown(keyCode: 33, characters: "[", modifiers: .control)

        XCTAssertTrue(consumed, "Ctrl+[ should be consumed")
        XCTAssertFalse(hintMode.isActive, "HintMode should be deactivated after Ctrl+[")
    }
}

// MARK: - Test Doubles

private class MockHintModeDelegate: HintModeDelegate {
    var didDeactivate = false
    var didSelectElement = false
    var selectedElement: ActionableElement?
    var selectedClickType: ClickType?

    func hintModeDidDeactivate() {
        didDeactivate = true
    }

    func hintModeDidSelectElement(_ element: ActionableElement, clickType: ClickType) {
        didSelectElement = true
        selectedElement = element
        selectedClickType = clickType
    }
}
