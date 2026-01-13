// Tests/KeyNavUITests/Helpers/TestApp.swift
import XCTest

/// Helper class for interacting with the KeyNav app during UI tests.
final class TestApp {
    let app: XCUIApplication

    init() {
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    // MARK: - Launch

    func launch() {
        app.launch()
    }

    func launchWithNoPermission() {
        app.launchArguments.append("--simulate-no-permission")
        app.launch()
    }

    func launchWithHotkeyFailure() {
        app.launchArguments.append("--simulate-hotkey-failure")
        app.launch()
    }

    // MARK: - Menu Bar

    /// Find the KeyNav status item in the menu bar
    var statusItem: XCUIElement {
        app.statusItems["KeyNav"]
    }

    /// Click on the status item to show the menu
    func clickStatusItem() {
        if statusItem.waitForExistence(timeout: 5) {
            statusItem.click()
        }
    }

    // MARK: - Menu Items

    func menuItem(_ title: String) -> XCUIElement {
        app.menuItems[title]
    }

    // MARK: - Windows

    var preferencesWindow: XCUIElement {
        app.windows["KeyNav Preferences"]
    }

    var onboardingWindow: XCUIElement {
        app.windows["KeyNav Setup"]
    }

    // MARK: - Preferences Navigation

    func openPreferences() {
        clickStatusItem()
        if menuItem("Preferences...").waitForExistence(timeout: 2) {
            menuItem("Preferences...").click()
        }
    }

    func selectPreferencesTab(_ name: String) {
        let tab = preferencesWindow.tabGroups.firstMatch.buttons[name]
        if tab.waitForExistence(timeout: 2) {
            tab.click()
        }
    }
}
