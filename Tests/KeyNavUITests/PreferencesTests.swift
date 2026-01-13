// Tests/KeyNavUITests/PreferencesTests.swift
import XCTest

/// UI tests for the Preferences window functionality.
final class PreferencesTests: XCTestCase {
    var testApp: TestApp!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        testApp = TestApp()
    }

    override func tearDown() {
        testApp = nil
        super.tearDown()
    }

    // MARK: - Window Opening

    func testPreferencesWindowOpens() throws {
        testApp.launch()

        testApp.openPreferences()

        let prefsWindow = testApp.preferencesWindow
        XCTAssertTrue(prefsWindow.waitForExistence(timeout: 3),
                      "Preferences window should open")
    }

    func testPreferencesWindowHasCorrectTitle() throws {
        testApp.launch()

        testApp.openPreferences()

        let prefsWindow = testApp.preferencesWindow
        XCTAssertTrue(prefsWindow.waitForExistence(timeout: 3))
        // Window title is verified by the accessor matching "KeyNav Preferences"
    }

    // MARK: - Tab Navigation

    func testPreferencesHasThreeTabs() throws {
        testApp.launch()

        testApp.openPreferences()

        let prefsWindow = testApp.preferencesWindow
        XCTAssertTrue(prefsWindow.waitForExistence(timeout: 3))

        let tabGroup = prefsWindow.tabGroups.firstMatch
        XCTAssertTrue(tabGroup.buttons["Shortcuts"].exists, "Shortcuts tab should exist")
        XCTAssertTrue(tabGroup.buttons["Hints"].exists, "Hints tab should exist")
        XCTAssertTrue(tabGroup.buttons["Diagnostic"].exists, "Diagnostic tab should exist")
    }

    func testTabNavigation() throws {
        testApp.launch()

        testApp.openPreferences()

        let prefsWindow = testApp.preferencesWindow
        XCTAssertTrue(prefsWindow.waitForExistence(timeout: 3))

        // Navigate to Hints tab
        testApp.selectPreferencesTab("Hints")
        // Tab should be selected (verify by checking some Hints-specific content exists)

        // Navigate to Diagnostic tab
        testApp.selectPreferencesTab("Diagnostic")
        // Tab should be selected

        // Navigate back to Shortcuts tab
        testApp.selectPreferencesTab("Shortcuts")
        // Tab should be selected
    }

    // MARK: - Shortcuts Tab

    func testShortcutsTabContent() throws {
        testApp.launch()

        testApp.openPreferences()
        testApp.selectPreferencesTab("Shortcuts")

        let prefsWindow = testApp.preferencesWindow

        // Look for mode shortcut labels
        let hintModeLabel = prefsWindow.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Hint Mode'")
        )
        let scrollModeLabel = prefsWindow.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Scroll Mode'")
        )
        let searchModeLabel = prefsWindow.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Search Mode'")
        )

        XCTAssertGreaterThan(hintModeLabel.count, 0, "Should show Hint Mode shortcut")
        XCTAssertGreaterThan(scrollModeLabel.count, 0, "Should show Scroll Mode shortcut")
        XCTAssertGreaterThan(searchModeLabel.count, 0, "Should show Search Mode shortcut")
    }

    // MARK: - Diagnostic Tab

    func testDiagnosticTabContent() throws {
        testApp.launch()

        testApp.openPreferences()
        testApp.selectPreferencesTab("Diagnostic")

        let prefsWindow = testApp.preferencesWindow

        // Should show status indicators
        let accessibilityLabel = prefsWindow.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Accessibility'")
        )
        XCTAssertGreaterThan(accessibilityLabel.count, 0, "Should show Accessibility status")
    }

    // MARK: - Permission Flow

    func testOnboardingWindowAppearsWithSimulatedNoPermission() throws {
        testApp.launchWithNoPermission()

        let onboarding = testApp.onboardingWindow
        XCTAssertTrue(onboarding.waitForExistence(timeout: 5),
                      "Onboarding window should appear when permission is not granted")
    }

    func testOnboardingHasOpenSettingsButton() throws {
        testApp.launchWithNoPermission()

        let onboarding = testApp.onboardingWindow
        XCTAssertTrue(onboarding.waitForExistence(timeout: 5))

        let openSettingsButton = onboarding.buttons["Open System Settings"]
        XCTAssertTrue(openSettingsButton.exists,
                      "Open System Settings button should exist in onboarding")
    }
}
