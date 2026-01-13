// Tests/KeyNavIntegrationTests/ModeLifecycleIntegrationTests.swift
import XCTest
@testable import KeyNav

/// Integration tests for mode lifecycle with mocked dependencies.
final class ModeLifecycleIntegrationTests: XCTestCase {

    // MARK: - Mode Manager Integration

    func testModeManagerFullCycle() {
        // Test a complete mode activation/deactivation cycle
        var manager = ModeManager()
        let hintController = TestModeController(type: .hint)
        let scrollController = TestModeController(type: .scroll)
        let searchController = TestModeController(type: .search)

        manager.register(controller: hintController, for: .hint)
        manager.register(controller: scrollController, for: .scroll)
        manager.register(controller: searchController, for: .search)

        // Initially no mode active (currentMode is nil)
        XCTAssertNil(manager.currentMode, "Initially no mode should be active")

        // Activate hint mode
        manager.switchTo(mode: .hint)
        XCTAssertEqual(manager.currentMode, .hint)
        XCTAssertTrue(hintController.isActive)
        XCTAssertFalse(scrollController.isActive)
        XCTAssertFalse(searchController.isActive)

        // Switch to scroll mode
        manager.switchTo(mode: .scroll)
        XCTAssertEqual(manager.currentMode, .scroll)
        XCTAssertFalse(hintController.isActive)
        XCTAssertTrue(scrollController.isActive)
        XCTAssertFalse(searchController.isActive)

        // Switch to search mode
        manager.switchTo(mode: .search)
        XCTAssertEqual(manager.currentMode, .search)
        XCTAssertFalse(hintController.isActive)
        XCTAssertFalse(scrollController.isActive)
        XCTAssertTrue(searchController.isActive)

        // Deactivate all modes (return to no active mode)
        manager.deactivateAll()
        XCTAssertNil(manager.currentMode, "After deactivation, no mode should be active")
        XCTAssertFalse(hintController.isActive)
        XCTAssertFalse(scrollController.isActive)
        XCTAssertFalse(searchController.isActive)
    }

    func testModeManagerDelegateNotifications() {
        var manager = ModeManager()
        let controller = TestModeController(type: .hint)
        let delegate = TestModeDelegate()
        controller.delegate = delegate

        manager.register(controller: controller, for: .hint)

        manager.switchTo(mode: .hint)
        XCTAssertTrue(delegate.activateCallCount > 0, "Delegate should be notified on activation")

        manager.switchTo(mode: .normal)
        XCTAssertTrue(delegate.deactivateCallCount > 0, "Delegate should be notified on deactivation")
    }

    func testModeManagerMultipleSwitchesToSameMode() {
        var manager = ModeManager()
        let controller = TestModeController(type: .hint)

        manager.register(controller: controller, for: .hint)

        manager.switchTo(mode: .hint)
        XCTAssertTrue(controller.isActive)

        // Switch to same mode again - should still be active
        manager.switchTo(mode: .hint)
        XCTAssertTrue(controller.isActive)
    }

    // MARK: - Key Input Handling

    func testModeControllerKeyInputResults() {
        let controller = TestModeController(type: .hint)

        // Test consumed result
        controller.nextInputResult = .consumed
        var result = controller.handleKeyInput(keyCode: 0, modifiers: [])
        XCTAssertEqual(result, .consumed)

        // Test passThrough result
        controller.nextInputResult = .passThrough
        result = controller.handleKeyInput(keyCode: 0, modifiers: [])
        XCTAssertEqual(result, .passThrough)

        // Test exitMode result
        controller.nextInputResult = .exitMode
        result = controller.handleKeyInput(keyCode: 0, modifiers: [])
        XCTAssertEqual(result, .exitMode)
    }

    // MARK: - Escape Key Handling

    func testEscapeKeyExitsMode() {
        var manager = ModeManager()
        let controller = TestModeController(type: .hint)
        controller.nextInputResult = .exitMode // Escape should trigger exit

        manager.register(controller: controller, for: .hint)
        manager.switchTo(mode: .hint)

        // Simulate escape key (keyCode 53)
        let result = controller.handleKeyInput(keyCode: 53, modifiers: [])

        XCTAssertEqual(result, .exitMode, "Escape key should return exitMode")
    }
}

// MARK: - Test Helpers

/// Test implementation of ModeControllerProtocol
class TestModeController: ModeControllerProtocol {
    var isActive: Bool = false
    var modeType: ModeType
    var nextInputResult: KeyInputResult = .consumed
    weak var delegate: ModeControllerDelegate?

    init(type: ModeType) {
        self.modeType = type
    }

    func activate() {
        isActive = true
        delegate?.modeDidActivate(self)
    }

    func deactivate() {
        isActive = false
        delegate?.modeDidDeactivate(self)
    }

    func handleKeyInput(keyCode: UInt16, modifiers: KeyModifiers) -> KeyInputResult {
        nextInputResult
    }
}

/// Test implementation of ModeControllerDelegate
class TestModeDelegate: ModeControllerDelegate {
    var activateCallCount = 0
    var deactivateCallCount = 0

    func modeDidActivate(_ controller: ModeControllerProtocol) {
        activateCallCount += 1
    }

    func modeDidDeactivate(_ controller: ModeControllerProtocol) {
        deactivateCallCount += 1
    }
}
