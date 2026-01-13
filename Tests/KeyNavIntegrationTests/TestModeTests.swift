// Tests/KeyNavIntegrationTests/TestModeTests.swift
import XCTest
@testable import KeyNav

/// Integration tests for TestMode configuration used in E2E testing.
final class TestModeTests: XCTestCase {

    // MARK: - TestMode Flag Detection

    func testTestModeUITestingFlagDefaultsFalse() {
        // By default, when not launched with --uitesting, flag should be false
        // Note: This test verifies the flag reads from ProcessInfo.processInfo.arguments
        XCTAssertFalse(TestMode.isUITesting, "isUITesting should be false when --uitesting argument not present")
    }

    func testTestModeSimulateNoPermissionFlagDefaultsFalse() {
        XCTAssertFalse(TestMode.simulateNoPermission, "simulateNoPermission should be false by default")
    }

    func testTestModeSimulateHotkeyFailureFlagDefaultsFalse() {
        XCTAssertFalse(TestMode.simulateHotkeyFailure, "simulateHotkeyFailure should be false by default")
    }

    // MARK: - AppStatus Integration

    func testAppStatusCanSimulateHotkeyFailure() {
        // Verify AppStatus accepts failure states (as would happen with --simulate-hotkey-failure)

        // Simulate failure via update method
        AppStatus.shared.updateHintModeHotkeyStatus(.failed(reason: "Test failure"))

        // Give async update time to complete
        let expectation = XCTestExpectation(description: "Status update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(AppStatus.shared.hasAnyFailure, "AppStatus should report failure")

        // Reset for other tests
        AppStatus.shared.reset()
    }

    // MARK: - ModeType Integration

    func testModeTypeEnumeration() {
        // Verify all mode types are available for testing
        let allModes: [ModeType] = [.hint, .scroll, .search, .normal]

        XCTAssertEqual(allModes.count, 4, "Should have 4 mode types")
        XCTAssertEqual(ModeType.hint.rawValue, "hint")
        XCTAssertEqual(ModeType.scroll.rawValue, "scroll")
        XCTAssertEqual(ModeType.search.rawValue, "search")
        XCTAssertEqual(ModeType.normal.rawValue, "normal")
    }
}
