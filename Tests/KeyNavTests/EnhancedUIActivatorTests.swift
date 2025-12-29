// Tests/KeyNavTests/EnhancedUIActivatorTests.swift
import XCTest
@testable import KeyNav

final class EnhancedUIActivatorTests: XCTestCase {

    // MARK: - Enhanced UI Attribute

    func testEnhancedUIAttribute() {
        let activator = EnhancedUIActivator()

        XCTAssertEqual(activator.enhancedUIAttribute, "AXEnhancedUserInterface")
    }

    // MARK: - Activation State

    func testInitialStateIsInactive() {
        let activator = EnhancedUIActivator()

        XCTAssertFalse(activator.isActivated)
    }

    func testActivateSetsState() {
        var activator = EnhancedUIActivator()

        activator.setActivated(true)

        XCTAssertTrue(activator.isActivated)
    }

    func testDeactivateClearsState() {
        var activator = EnhancedUIActivator()

        activator.setActivated(true)
        activator.setActivated(false)

        XCTAssertFalse(activator.isActivated)
    }

    // MARK: - App-Specific Activation

    func testTracksActivatedApps() {
        var activator = EnhancedUIActivator()
        let testPID: pid_t = 1234

        activator.activateForApp(pid: testPID)

        XCTAssertTrue(activator.isActivatedFor(pid: testPID))
        XCTAssertFalse(activator.isActivatedFor(pid: 5678))
    }

    func testDeactivatesForApp() {
        var activator = EnhancedUIActivator()
        let testPID: pid_t = 1234

        activator.activateForApp(pid: testPID)
        activator.deactivateForApp(pid: testPID)

        XCTAssertFalse(activator.isActivatedFor(pid: testPID))
    }

    func testDeactivatesAllApps() {
        var activator = EnhancedUIActivator()

        activator.activateForApp(pid: 1234)
        activator.activateForApp(pid: 5678)
        activator.deactivateAll()

        XCTAssertFalse(activator.isActivatedFor(pid: 1234))
        XCTAssertFalse(activator.isActivatedFor(pid: 5678))
    }
}
