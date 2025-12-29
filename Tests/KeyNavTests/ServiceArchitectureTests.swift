// Tests/KeyNavTests/ServiceArchitectureTests.swift
import XCTest
@testable import KeyNav

final class ServiceArchitectureTests: XCTestCase {

    // MARK: - QueryWindowService

    func testQueryWindowServiceProtocol() {
        let service = MockQueryWindowService()

        XCTAssertTrue(service is QueryWindowServiceProtocol)
    }

    func testQueryWindowServiceReturnsWindows() {
        let service = MockQueryWindowService()
        service.mockWindows = [
            WindowInfo(id: 1, title: "Window 1", frame: CGRect(x: 0, y: 0, width: 800, height: 600)),
            WindowInfo(id: 2, title: "Window 2", frame: CGRect(x: 100, y: 100, width: 400, height: 300))
        ]

        let windows = service.queryWindows(for: "TestApp")

        XCTAssertEqual(windows.count, 2)
    }

    func testQueryWindowServiceFiltersMinimized() {
        let service = MockQueryWindowService()
        service.mockWindows = [
            WindowInfo(id: 1, title: "Visible", frame: CGRect(x: 0, y: 0, width: 800, height: 600), isMinimized: false),
            WindowInfo(id: 2, title: "Minimized", frame: CGRect(x: 0, y: 0, width: 400, height: 300), isMinimized: true)
        ]

        let windows = service.queryVisibleWindows(for: "TestApp")

        XCTAssertEqual(windows.count, 1)
        XCTAssertEqual(windows.first?.title, "Visible")
    }

    // MARK: - QueryMenuBarItemsService

    func testQueryMenuBarItemsServiceProtocol() {
        let service = MockQueryMenuBarItemsService()

        XCTAssertTrue(service is QueryMenuBarItemsServiceProtocol)
    }

    func testQueryMenuBarItemsReturnsItems() {
        let service = MockQueryMenuBarItemsService()
        service.mockItems = [
            MenuBarItem(title: "File", position: CGPoint(x: 10, y: 10)),
            MenuBarItem(title: "Edit", position: CGPoint(x: 50, y: 10))
        ]

        let items = service.queryMenuBarItems(for: "TestApp")

        XCTAssertEqual(items.count, 2)
    }

    // MARK: - QueryMenuBarExtrasService

    func testQueryMenuBarExtrasServiceProtocol() {
        let service = MockQueryMenuBarExtrasService()

        XCTAssertTrue(service is QueryMenuBarExtrasServiceProtocol)
    }

    func testQueryMenuBarExtrasReturnsExtras() {
        let service = MockQueryMenuBarExtrasService()
        service.mockExtras = [
            MenuBarExtra(identifier: "com.apple.wifi", position: CGPoint(x: 1200, y: 10)),
            MenuBarExtra(identifier: "com.apple.battery", position: CGPoint(x: 1250, y: 10))
        ]

        let extras = service.queryMenuBarExtras()

        XCTAssertEqual(extras.count, 2)
    }

    // MARK: - QueryNotificationCenterItemsService

    func testQueryNotificationCenterServiceProtocol() {
        let service = MockQueryNotificationCenterItemsService()

        XCTAssertTrue(service is QueryNotificationCenterItemsServiceProtocol)
    }

    func testQueryNotificationCenterReturnsItems() {
        let service = MockQueryNotificationCenterItemsService()
        service.mockItems = [
            NotificationCenterItem(title: "Do Not Disturb", isToggle: true),
            NotificationCenterItem(title: "Focus", isToggle: true)
        ]

        let items = service.queryNotificationCenterItems()

        XCTAssertEqual(items.count, 2)
    }

    // MARK: - TraverseElementServiceFinder

    func testTraverseElementServiceFinderProtocol() {
        let finder = MockTraverseElementServiceFinder()

        XCTAssertTrue(finder is TraverseElementServiceFinderProtocol)
    }

    func testTraverseElementServiceFinderSelectsCorrectService() {
        let finder = MockTraverseElementServiceFinder()
        finder.mockServiceType = .webArea

        let serviceType = finder.findService(for: MockElement(role: "AXWebArea"))

        XCTAssertEqual(serviceType, .webArea)
    }

    func testTraverseElementServiceFinderDefaultsToStandard() {
        let finder = MockTraverseElementServiceFinder()
        finder.mockServiceType = .standard

        let serviceType = finder.findService(for: MockElement(role: "AXButton"))

        XCTAssertEqual(serviceType, .standard)
    }

    // MARK: - Service Registry

    func testServiceRegistryRegistersServices() {
        var registry = ServiceRegistry()

        registry.register(windowService: MockQueryWindowService())
        registry.register(menuBarItemsService: MockQueryMenuBarItemsService())

        XCTAssertNotNil(registry.windowService)
        XCTAssertNotNil(registry.menuBarItemsService)
    }

    func testServiceRegistryReturnsRegisteredServices() {
        var registry = ServiceRegistry()
        let windowService = MockQueryWindowService()

        registry.register(windowService: windowService)

        XCTAssertTrue(registry.windowService is MockQueryWindowService)
    }
}

// MARK: - Mock Implementations

class MockQueryWindowService: QueryWindowServiceProtocol {
    var mockWindows: [WindowInfo] = []

    func queryWindows(for appName: String) -> [WindowInfo] {
        mockWindows
    }

    func queryVisibleWindows(for appName: String) -> [WindowInfo] {
        mockWindows.filter { !$0.isMinimized }
    }
}

class MockQueryMenuBarItemsService: QueryMenuBarItemsServiceProtocol {
    var mockItems: [MenuBarItem] = []

    func queryMenuBarItems(for appName: String) -> [MenuBarItem] {
        mockItems
    }
}

class MockQueryMenuBarExtrasService: QueryMenuBarExtrasServiceProtocol {
    var mockExtras: [MenuBarExtra] = []

    func queryMenuBarExtras() -> [MenuBarExtra] {
        mockExtras
    }
}

class MockQueryNotificationCenterItemsService: QueryNotificationCenterItemsServiceProtocol {
    var mockItems: [NotificationCenterItem] = []

    func queryNotificationCenterItems() -> [NotificationCenterItem] {
        mockItems
    }
}

class MockTraverseElementServiceFinder: TraverseElementServiceFinderProtocol {
    var mockServiceType: TraversalServiceType = .standard

    func findService(for element: ElementProtocol) -> TraversalServiceType {
        mockServiceType
    }
}

class MockElement: ElementProtocol {
    let role: String

    init(role: String) {
        self.role = role
    }
}
