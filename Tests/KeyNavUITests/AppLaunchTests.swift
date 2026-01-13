// Tests/KeyNavUITests/AppLaunchTests.swift
import XCTest

/// UI tests for app launch behavior and menu bar functionality.
final class AppLaunchTests: XCTestCase {
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

    // MARK: - App Launch

    func testAppLaunchesAsMenuBarApp() throws {
        testApp.launch()

        // Give the app time to initialize
        sleep(1)

        // App should not have a main window (it's a menu bar app)
        XCTAssertFalse(testApp.app.windows["MainWindow"].exists,
                       "Menu bar app should not have a main window")
    }

    func testStatusItemAppears() throws {
        testApp.launch()

        // Status item should appear in menu bar
        let statusItem = testApp.statusItem
        XCTAssertTrue(statusItem.waitForExistence(timeout: 5),
                      "Status item should appear in menu bar")
    }

    // MARK: - Menu Bar Menu

    func testStatusItemShowsMenu() throws {
        testApp.launch()

        testApp.clickStatusItem()

        // Menu items should appear
        XCTAssertTrue(testApp.menuItem("Preferences...").waitForExistence(timeout: 2),
                      "Preferences menu item should exist")
        XCTAssertTrue(testApp.menuItem("Quit KeyNav").exists,
                      "Quit menu item should exist")
    }

    func testMenuShowsStatusIndicator() throws {
        testApp.launch()

        testApp.clickStatusItem()

        // Status should show (either Active or Issues Detected)
        let statusActive = testApp.app.menuItems["Status: Active"]
        let statusIssues = testApp.app.menuItems["Status: Issues Detected"]
        let statusStarting = testApp.app.menuItems["Status: Starting..."]

        XCTAssertTrue(
            statusActive.exists || statusIssues.exists || statusStarting.exists,
            "Menu should show status indicator"
        )
    }

    // MARK: - Simulated States

    func testTroubleshootAppearsOnHotkeyFailure() throws {
        testApp.launchWithHotkeyFailure()

        // Give time for simulated failure to be processed
        sleep(1)

        testApp.clickStatusItem()

        // Troubleshoot menu item should appear when there are issues
        XCTAssertTrue(testApp.menuItem("Troubleshoot...").waitForExistence(timeout: 2),
                      "Troubleshoot menu item should appear when hotkey registration fails")
    }
}
