// Tests/KeyNavTests/KeyboardEventCaptureTests.swift
import XCTest
@testable import KeyNav

final class KeyboardEventCaptureTests: XCTestCase {

    // MARK: - Mock Keyboard Event Capture Tests

    func testMockStartCapturing() {
        let capture = MockKeyboardEventCapture()
        XCTAssertFalse(capture.isCapturing)

        capture.startCapturing()

        XCTAssertTrue(capture.isCapturing)
        XCTAssertEqual(capture.startCapturingCallCount, 1)
    }

    func testMockStopCapturing() {
        let capture = MockKeyboardEventCapture()
        capture.startCapturing()
        XCTAssertTrue(capture.isCapturing)

        capture.stopCapturing()

        XCTAssertFalse(capture.isCapturing)
        XCTAssertEqual(capture.stopCapturingCallCount, 1)
    }

    func testMockSimulateKeyDownCallsDelegate() {
        let capture = MockKeyboardEventCapture()
        let delegate = MockKeyboardEventCaptureDelegate()
        capture.delegate = delegate

        _ = capture.simulateKeyDown(keyCode: 0, characters: "a")

        XCTAssertEqual(delegate.receivedKeyCodes.count, 1)
        XCTAssertEqual(delegate.receivedKeyCodes[0], 0)
        XCTAssertEqual(delegate.receivedCharacters[0], "a")
    }

    func testMockSimulateKeyDownReturnsConsumedResult() {
        let capture = MockKeyboardEventCapture()
        let delegate = MockKeyboardEventCaptureDelegate()
        delegate.shouldConsume = true
        capture.delegate = delegate

        let consumed = capture.simulateKeyDown(keyCode: 0, characters: "a")

        XCTAssertTrue(consumed)
    }

    func testMockSimulateKeyDownReturnsNotConsumedResult() {
        let capture = MockKeyboardEventCapture()
        let delegate = MockKeyboardEventCaptureDelegate()
        delegate.shouldConsume = false
        capture.delegate = delegate

        let consumed = capture.simulateKeyDown(keyCode: 0, characters: "a")

        XCTAssertFalse(consumed)
    }
}

// MARK: - Test Double

private class MockKeyboardEventCaptureDelegate: KeyboardEventCaptureDelegate {
    var receivedKeyCodes: [UInt16] = []
    var receivedCharacters: [String?] = []
    var receivedModifiers: [KeyModifiers] = []
    var shouldConsume = false

    func keyboardEventCapture(_ capture: KeyboardEventCapture, didReceiveKeyDown keyCode: UInt16, characters: String?, modifiers: KeyModifiers) -> Bool {
        receivedKeyCodes.append(keyCode)
        receivedCharacters.append(characters)
        receivedModifiers.append(modifiers)
        return shouldConsume
    }
}
