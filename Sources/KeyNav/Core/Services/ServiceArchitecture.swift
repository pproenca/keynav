// Sources/KeyNav/Core/Services/ServiceArchitecture.swift
import Foundation

// MARK: - Data Types

/// Information about a window
struct WindowInfo: Equatable {
    let id: Int
    let title: String
    let frame: CGRect
    var isMinimized: Bool = false
}

/// A menu bar item
struct MenuBarItem: Equatable {
    let title: String
    let position: CGPoint
}

/// A menu bar extra (status bar item)
struct MenuBarExtra: Equatable {
    let identifier: String
    let position: CGPoint
}

/// A notification center item
struct NotificationCenterItem: Equatable {
    let title: String
    let isToggle: Bool
}

/// Types of traversal services available
enum TraversalServiceType: Equatable {
    case standard
    case webArea
    case table
    case menuBar
}

// MARK: - Element Protocol

/// Protocol for accessibility elements
protocol ElementProtocol {
    var role: String { get }
}

// MARK: - Service Protocols

/// Protocol for querying windows
protocol QueryWindowServiceProtocol {
    func queryWindows(for appName: String) -> [WindowInfo]
    func queryVisibleWindows(for appName: String) -> [WindowInfo]
}

/// Protocol for querying menu bar items
protocol QueryMenuBarItemsServiceProtocol {
    func queryMenuBarItems(for appName: String) -> [MenuBarItem]
}

/// Protocol for querying menu bar extras
protocol QueryMenuBarExtrasServiceProtocol {
    func queryMenuBarExtras() -> [MenuBarExtra]
}

/// Protocol for querying notification center items
protocol QueryNotificationCenterItemsServiceProtocol {
    func queryNotificationCenterItems() -> [NotificationCenterItem]
}

/// Protocol for finding the appropriate traversal service for an element
protocol TraverseElementServiceFinderProtocol {
    func findService(for element: ElementProtocol) -> TraversalServiceType
}

// MARK: - Service Registry

/// Registry for service instances
struct ServiceRegistry {
    private(set) var windowService: QueryWindowServiceProtocol?
    private(set) var menuBarItemsService: QueryMenuBarItemsServiceProtocol?
    private(set) var menuBarExtrasService: QueryMenuBarExtrasServiceProtocol?
    private(set) var notificationCenterService: QueryNotificationCenterItemsServiceProtocol?
    private(set) var traversalServiceFinder: TraverseElementServiceFinderProtocol?

    mutating func register(windowService: QueryWindowServiceProtocol) {
        self.windowService = windowService
    }

    mutating func register(menuBarItemsService: QueryMenuBarItemsServiceProtocol) {
        self.menuBarItemsService = menuBarItemsService
    }

    mutating func register(menuBarExtrasService: QueryMenuBarExtrasServiceProtocol) {
        self.menuBarExtrasService = menuBarExtrasService
    }

    mutating func register(notificationCenterService: QueryNotificationCenterItemsServiceProtocol) {
        self.notificationCenterService = notificationCenterService
    }

    mutating func register(traversalServiceFinder: TraverseElementServiceFinderProtocol) {
        self.traversalServiceFinder = traversalServiceFinder
    }
}
