// Tests/KeyNavTests/ManualActivatorTests.swift
import XCTest
@testable import KeyNav

final class ManualActivatorTests: XCTestCase {

    // MARK: - Fallback Activation

    func testManualActivatorIsFallback() {
        let activator = ManualAccessibilityActivator()

        XCTAssertTrue(activator.isFallbackMethod)
    }

    // MARK: - Activation Methods

    func testSupportedActivationMethods() {
        let activator = ManualAccessibilityActivator()

        XCTAssertTrue(activator.supportedMethods.contains(.keyboard))
        XCTAssertTrue(activator.supportedMethods.contains(.accessibility))
    }

    func testPreferredMethod() {
        let activator = ManualAccessibilityActivator()

        // Accessibility should be preferred when available
        XCTAssertEqual(activator.preferredMethod, .accessibility)
    }

    // MARK: - Activation State

    func testInitialStateIsNotActive() {
        let activator = ManualAccessibilityActivator()

        XCTAssertFalse(activator.isActive)
    }

    func testSetActiveState() {
        var activator = ManualAccessibilityActivator()

        activator.setActive(true)

        XCTAssertTrue(activator.isActive)
    }

    // MARK: - Method Selection

    func testFallbackToKeyboard() {
        var activator = ManualAccessibilityActivator()

        activator.setAccessibilityAvailable(false)

        XCTAssertEqual(activator.currentMethod, .keyboard)
    }

    func testUseAccessibilityWhenAvailable() {
        var activator = ManualAccessibilityActivator()

        activator.setAccessibilityAvailable(true)

        XCTAssertEqual(activator.currentMethod, .accessibility)
    }
}
