// Tests/KeyNavTests/HoldKeyActivationTests.swift
import XCTest
@testable import KeyNav

final class HoldKeyActivationTests: XCTestCase {

    // MARK: - Hold Configuration

    func testDefaultHoldThreshold() {
        let config = HoldKeyConfig()

        XCTAssertEqual(config.holdThreshold, 0.25, accuracy: 0.01)
    }

    func testCustomHoldThreshold() {
        let config = HoldKeyConfig(holdThreshold: 0.5)

        XCTAssertEqual(config.holdThreshold, 0.5, accuracy: 0.01)
    }

    // MARK: - Hold State Machine

    func testInitialStateIsIdle() {
        let stateMachine = HoldKeyStateMachine()

        XCTAssertEqual(stateMachine.state, .idle)
    }

    func testKeyDownStartsHolding() {
        var stateMachine = HoldKeyStateMachine()

        stateMachine.keyDown(keyCode: 49)  // Space bar

        XCTAssertEqual(stateMachine.state, .holding)
        XCTAssertEqual(stateMachine.heldKeyCode, 49)
    }

    func testQuickReleaseTransitionsToReplay() {
        var stateMachine = HoldKeyStateMachine()

        stateMachine.keyDown(keyCode: 49)
        let action = stateMachine.keyUp(keyCode: 49, heldDuration: 0.1)

        XCTAssertEqual(stateMachine.state, .idle)
        XCTAssertEqual(action, .replayKeypress)
    }

    func testLongHoldTransitionsToActivated() {
        var stateMachine = HoldKeyStateMachine()

        stateMachine.keyDown(keyCode: 49)
        let action = stateMachine.keyUp(keyCode: 49, heldDuration: 0.3)

        XCTAssertEqual(stateMachine.state, .idle)
        XCTAssertEqual(action, .activate)
    }

    // MARK: - Auto-Repeat Suppression

    func testSuppressAutoRepeat() {
        var stateMachine = HoldKeyStateMachine()

        stateMachine.keyDown(keyCode: 49)
        let shouldSuppress = stateMachine.shouldSuppressRepeat(keyCode: 49)

        XCTAssertTrue(shouldSuppress)
    }

    func testDontSuppressOtherKeys() {
        var stateMachine = HoldKeyStateMachine()

        stateMachine.keyDown(keyCode: 49)
        let shouldSuppress = stateMachine.shouldSuppressRepeat(keyCode: 50)

        XCTAssertFalse(shouldSuppress)
    }

    // MARK: - Modifier Edge Case

    func testModifierChangeAborts() {
        var stateMachine = HoldKeyStateMachine()

        // Space down without modifiers
        stateMachine.keyDown(keyCode: 49, modifiers: [])

        // Shift-Space up (modifier added during hold)
        let action = stateMachine.keyUp(keyCode: 49, heldDuration: 0.3, modifiers: [.shift])

        // Should abort activation due to modifier change
        XCTAssertEqual(action, .abort)
    }

    func testSameModifiersActivates() {
        var stateMachine = HoldKeyStateMachine()

        stateMachine.keyDown(keyCode: 49, modifiers: [.shift])
        let action = stateMachine.keyUp(keyCode: 49, heldDuration: 0.3, modifiers: [.shift])

        XCTAssertEqual(action, .activate)
    }

    // MARK: - Configurable Key

    func testConfigurableActivationKey() {
        let config = HoldKeyConfig(activationKeyCode: 36)  // Return key

        XCTAssertEqual(config.activationKeyCode, 36)
    }

    func testDefaultActivationKeyIsSpace() {
        let config = HoldKeyConfig()

        XCTAssertEqual(config.activationKeyCode, 49)  // Space bar
    }
}
