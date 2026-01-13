import AppKit
// Sources/KeyNav/Accessibility/MenuTraversal.swift
import ApplicationServices

/// Helper class for traversing open menu items
/// Separates complex menu detection logic from ElementTraversal
final class MenuTraversal {

    private let traversal: ElementTraversal

    init(traversal: ElementTraversal) {
        self.traversal = traversal
    }

    /// Get open menu items (dropdown menus that are currently visible)
    /// In macOS, open menus can be exposed as children of the focused UI element
    /// or as separate AXMenu windows
    func findOpenMenus(from app: AXUIElement) -> [ActionableElement] {
        var results: [ActionableElement] = []

        // Method 1: Check the focused UI element
        results.append(contentsOf: findMenusFromFocusedElement(app))

        // Method 2: Check all windows for popup menus
        results.append(contentsOf: findMenusFromWindows(app))

        return results
    }

    // MARK: - Method 1: Focused Element

    private func findMenusFromFocusedElement(_ app: AXUIElement) -> [ActionableElement] {
        var results: [ActionableElement] = []

        guard
            let axFocused = AXHelpers.getElement(
                from: app,
                attribute: kAXFocusedUIElementAttribute as CFString
            )
        else {
            return results
        }

        guard let role = traversal.getRole(of: axFocused) else {
            return results
        }

        // Check if the focused element is a menu or menu item
        if role == "AXMenu" || role == "AXMenuItem" {
            results.append(contentsOf: traversal.traverseMenuElements(from: axFocused))
        }

        // Also check parent - menu items have the menu as parent
        results.append(contentsOf: findMenusFromParent(of: axFocused))

        return results
    }

    private func findMenusFromParent(of element: AXUIElement) -> [ActionableElement] {
        guard
            let parent = AXHelpers.getElement(
                from: element,
                attribute: kAXParentAttribute as CFString
            )
        else {
            return []
        }

        guard let parentRole = traversal.getRole(of: parent), parentRole == "AXMenu" else {
            return []
        }

        return traversal.traverseMenuElements(from: parent)
    }

    // MARK: - Method 2: Window Traversal

    private func findMenusFromWindows(_ app: AXUIElement) -> [ActionableElement] {
        var results: [ActionableElement] = []

        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &windowsRef) == .success,
            let windows = windowsRef as? [AXUIElement]
        else {
            return results
        }

        for window in windows {
            results.append(contentsOf: findMenusInWindow(window))
        }

        return results
    }

    private func findMenusInWindow(_ window: AXUIElement) -> [ActionableElement] {
        var results: [ActionableElement] = []

        // Check if window itself is a menu
        if isMenuWindow(window) {
            results.append(contentsOf: traversal.traverseMenuElements(from: window))
        }

        // Also traverse window children looking for AXMenu elements
        let children = traversal.getChildren(of: window)
        for child in children {
            if let childRole = traversal.getRole(of: child), childRole == "AXMenu" {
                results.append(contentsOf: traversal.traverseMenuElements(from: child))
            }
        }

        return results
    }

    private func isMenuWindow(_ window: AXUIElement) -> Bool {
        guard let role = traversal.getRole(of: window) else { return false }

        // Some apps expose menus as windows with specific subroles
        var subroleRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleRef) == .success,
            let subrole = subroleRef as? String
        {
            return subrole == "AXMenu" || role == "AXMenu"
        }

        return role == "AXMenu"
    }
}
