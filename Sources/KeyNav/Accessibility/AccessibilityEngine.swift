import AppKit
// Sources/KeyNav/Accessibility/AccessibilityEngine.swift
import ApplicationServices

final class AccessibilityEngine {
    private let traversal = ElementTraversal()
    private let queue = DispatchQueue(label: "com.keynav.accessibility", qos: .userInteractive)

    func getActionableElements(completion: @escaping ([ActionableElement]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            let elements = self.getActionableElementsSync()
            DispatchQueue.main.async { completion(elements) }
        }
    }

    func getActionableElementsSync() -> [ActionableElement] {
        guard PermissionManager.shared.isAccessibilityEnabled else { return [] }

        // Debug: print accessibility hierarchy (only in debug builds)
        #if DEBUG
            AccessibilityDebug.printFocusedElementHierarchy()
        #endif

        var allElements: [ActionableElement] = []

        // Get frontmost app for menu bar and window elements
        if let app = traversal.getFrontmostApplication() {
            // 1. Menu bar items (File, Edit, View, etc.) - includes open menu items
            let menuBarItems = traversal.getMenuBarItems(from: app)
            allElements.append(contentsOf: menuBarItems)

            // 2. CRITICAL: The focused "window" might BE the menu when a menu is open!
            // Vimac's key insight: kAXFocusedWindowAttribute returns the menu itself
            if let focusedWindow = traversal.getFocusedWindow(from: app) {
                let focusedRole = traversal.getRole(of: focusedWindow)

                // If the "focused window" is actually a menu, traverse it as a menu
                if focusedRole == "AXMenu" {
                    let menuElements = traversal.traverseMenuElements(from: focusedWindow)
                    allElements.append(contentsOf: menuElements)
                } else {
                    // Normal window - traverse normally
                    let windowElements = traversal.traverseElements(from: focusedWindow)
                    allElements.append(contentsOf: windowElements)
                }
            }

            // 3. Also check focused UI element for menu context
            if let focusedElement = traversal.getFocusedUIElement(from: app) {
                let focusedRole = traversal.getRole(of: focusedElement)

                if focusedRole == "AXMenu" || focusedRole == "AXMenuItem" {
                    let menuElements = traversal.traverseFromMenuRoot(focusedElement)
                    allElements.append(contentsOf: menuElements)
                }
            }

            // 4. Check for any additional open menu windows
            let openMenuElements = traversal.getOpenMenuItems(from: app)
            allElements.append(contentsOf: openMenuElements)
        }

        // 5. Menu bar extras (system tray: Wi-Fi, battery, clock, etc.)
        let menuBarExtras = traversal.getMenuBarExtras()
        allElements.append(contentsOf: menuBarExtras)

        // 6. Notification center items (if visible)
        let notificationItems = traversal.getNotificationCenterItems()
        allElements.append(contentsOf: notificationItems)

        // Remove duplicates based on frame (same position = same element)
        var seen = Set<String>()
        allElements = allElements.filter { element in
            let frame = element.frame
            let key = "\(frame.origin.x),\(frame.origin.y),\(frame.width),\(frame.height)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }

        return allElements
    }

    func getAllWindowElements(completion: @escaping ([ActionableElement]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            var allElements: [ActionableElement] = []

            let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }

            for app in runningApps {
                let axApp = AXUIElementCreateApplication(app.processIdentifier)

                var windowsRef: CFTypeRef?
                guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef) == .success,
                    let windows = windowsRef as? [AXUIElement]
                else { continue }

                for window in windows {
                    let elements = self.traversal.traverseElements(from: window)
                    allElements.append(contentsOf: elements)
                }
            }

            DispatchQueue.main.async { completion(allElements) }
        }
    }

    func performClick(on element: ActionableElement) {
        guard let axElement = element.axElement else { return }

        if element.actions.contains("AXPress") {
            AXUIElementPerformAction(axElement, kAXPressAction as CFString)
        } else if element.actions.contains("AXConfirm") {
            AXUIElementPerformAction(axElement, kAXConfirmAction as CFString)
        } else {
            // Fallback: simulate mouse click at optimal position for element type
            let clickPoint = ClickPositionCalculator.clickPosition(for: element)
            simulateClick(at: clickPoint)
        }
    }

    func performDoubleClick(on element: ActionableElement) {
        let clickPoint = ClickPositionCalculator.clickPosition(for: element)
        simulateClick(at: clickPoint, clickCount: 2)
    }

    func performRightClick(on element: ActionableElement) {
        let clickPoint = ClickPositionCalculator.clickPosition(for: element)
        simulateRightClick(at: clickPoint)
    }

    func moveMouse(to element: ActionableElement) {
        let clickPoint = ClickPositionCalculator.clickPosition(for: element)
        CGWarpMouseCursorPosition(clickPoint)
    }

    private func simulateClick(at point: CGPoint, clickCount: Int = 1) {
        let mouseDown = CGEvent(
            mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left
        )
        let mouseUp = CGEvent(
            mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left
        )

        mouseDown?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))
        mouseUp?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }

    private func simulateRightClick(at point: CGPoint) {
        let mouseDown = CGEvent(
            mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: point, mouseButton: .right
        )
        let mouseUp = CGEvent(
            mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: point, mouseButton: .right
        )

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
}
