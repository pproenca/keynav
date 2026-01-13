// Sources/KeyNav/Accessibility/ElementTraversal.swift
import ApplicationServices
import AppKit

final class ElementTraversal {

    private let clickableRoles: Set<String> = [
        "AXButton",
        "AXLink",
        "AXCheckBox",
        "AXRadioButton",
        "AXMenuItem",
        "AXMenuBarItem",
        "AXCell",
        "AXPopUpButton",
        "AXComboBox",
        "AXTextField",
        "AXTextArea",
        "AXSlider",
        "AXIncrementor",
        "AXColorWell",
        "AXToolbarButton",
        "AXTab",
        "AXTabGroup"
    ]

    func isClickableRole(_ role: String) -> Bool {
        clickableRoles.contains(role)
    }

    func getFrontmostApplication() -> AXUIElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        return AXUIElementCreateApplication(app.processIdentifier)
    }

    func getFocusedWindow(from app: AXUIElement) -> AXUIElement? {
        AXHelpers.getElement(from: app, attribute: kAXFocusedWindowAttribute as CFString)
    }

    /// Get the focused UI element - this can be a menu when a menu is open
    func getFocusedUIElement(from app: AXUIElement) -> AXUIElement? {
        AXHelpers.getElement(from: app, attribute: kAXFocusedUIElementAttribute as CFString)
    }

    func getMenuBar(from app: AXUIElement) -> AXUIElement? {
        AXHelpers.getElement(from: app, attribute: kAXMenuBarAttribute as CFString)
    }

    func getExtrasMenuBar(from app: AXUIElement) -> AXUIElement? {
        AXHelpers.getElement(from: app, attribute: "AXExtrasMenuBar" as CFString)
    }

    func getChildren(of element: AXUIElement) -> [AXUIElement] {
        var childrenRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenRef)
        guard result == .success, let children = childrenRef as? [AXUIElement] else { return [] }
        return children
    }

    func getRole(of element: AXUIElement) -> String? {
        var roleRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef)
        guard result == .success else { return nil }
        return roleRef as? String
    }

    func getLabel(of element: AXUIElement) -> String {
        // Try AXTitle first
        var titleRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &titleRef) == .success,
           let title = titleRef as? String, !title.isEmpty {
            return title
        }

        // Try AXDescription
        var descRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXDescriptionAttribute as CFString, &descRef) == .success,
           let desc = descRef as? String, !desc.isEmpty {
            return desc
        }

        // Try AXValue
        var valueRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueRef) == .success,
           let value = valueRef as? String, !value.isEmpty {
            return value
        }

        return ""
    }

    func getFrame(of element: AXUIElement) -> CGRect? {
        AXHelpers.getFrame(from: element)
    }

    func getActions(of element: AXUIElement) -> [String] {
        var actionsRef: CFArray?
        let result = AXUIElementCopyActionNames(element, &actionsRef)
        guard result == .success, let actions = actionsRef as? [String] else { return [] }
        return actions
    }

    func getIdentifier(of element: AXUIElement) -> String? {
        var identifierRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXIdentifierAttribute as CFString, &identifierRef)
        guard result == .success else { return nil }
        return identifierRef as? String
    }

    func isEnabled(element: AXUIElement) -> Bool {
        var enabledRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXEnabledAttribute as CFString, &enabledRef)
        guard result == .success else { return true } // Assume enabled if attribute missing
        return (enabledRef as? Bool) ?? true
    }

    /// Get menu bar items from the frontmost app (File, Edit, View, etc.)
    /// Also traverses into any open menus to get their menu items
    func getMenuBarItems(from app: AXUIElement) -> [ActionableElement] {
        guard let menuBar = getMenuBar(from: app) else { return [] }
        let menuBarItems = getChildren(of: menuBar)

        var results: [ActionableElement] = []

        for menuBarItem in menuBarItems {
            guard let role = getRole(of: menuBarItem),
                  let frame = getFrame(of: menuBarItem),
                  frame.width > 0, frame.height > 0 else { continue }

            let label = getLabel(of: menuBarItem)
            let actions = getActions(of: menuBarItem)

            // Add the menu bar item itself (File, Edit, etc.)
            let actionable = ActionableElement(
                axElement: menuBarItem,
                role: role,
                label: label.isEmpty ? "Menu" : label,
                frame: frame,
                actions: actions,
                identifier: getIdentifier(of: menuBarItem)
            )
            results.append(actionable)

            // Traverse into children (open menu items) if any exist
            // When a menu is open, its items are children of the menu bar item
            let menuChildren = getChildren(of: menuBarItem)
            for menuChild in menuChildren {
                results.append(contentsOf: traverseMenuElements(from: menuChild))
            }
        }

        return results
    }

    /// Find the root menu element and traverse all its items
    func traverseFromMenuRoot(_ element: AXUIElement) -> [ActionableElement] {
        // Go up the parent chain to find the root menu
        var current = element
        var visited = Set<String>()

        while true {
            // Create a unique identifier to prevent infinite loops
            let elementDesc = String(describing: current)
            if visited.contains(elementDesc) {
                break
            }
            visited.insert(elementDesc)

            if let parent = AXHelpers.getElement(from: current, attribute: kAXParentAttribute as CFString) {
                let parentRole = getRole(of: parent)

                // Stop if we've gone past menus (hit the menu bar or app)
                if parentRole == "AXMenuBar" || parentRole == "AXApplication" || parentRole == nil {
                    break
                }

                // If parent is still a menu, keep going up
                if parentRole == "AXMenu" || parentRole == "AXMenuBarItem" {
                    current = parent
                } else {
                    break
                }
            } else {
                break
            }
        }

        // Now traverse from the root menu element
        return traverseMenuElements(from: current)
    }

    /// Recursively traverse menu elements (handles nested submenus)
    /// Following Vimac's approach: include elements with actions, not requiring labels
    func traverseMenuElements(from element: AXUIElement, maxDepth: Int = 10, currentDepth: Int = 0) -> [ActionableElement] {
        guard currentDepth < maxDepth else { return [] }

        var results: [ActionableElement] = []

        guard let role = getRole(of: element) else {
            // Still traverse children even if this element has no role
            let children = getChildren(of: element)
            for child in children {
                results.append(contentsOf: traverseMenuElements(from: child, maxDepth: maxDepth, currentDepth: currentDepth + 1))
            }
            return results
        }

        // Skip the menu container itself but process its children
        if role == "AXMenu" {
            let children = getChildren(of: element)
            for child in children {
                results.append(contentsOf: traverseMenuElements(from: child, maxDepth: maxDepth, currentDepth: currentDepth + 1))
            }
            return results
        }

        // Get frame for positioning
        if let frame = getFrame(of: element),
           frame.width > 0, frame.height > 0 {

            let label = getLabel(of: element)
            let actions = getActions(of: element)

            // Following Vimac's isActionable logic:
            // Include if it has any useful actions (not just AXShowMenu, etc.)
            let ignoredActions: Set<String> = ["AXShowMenu", "AXScrollToVisible", "AXShowDefaultUI", "AXShowAlternateUI"]
            let usefulActions = Set(actions).subtracting(ignoredActions)

            let isActionable = !usefulActions.isEmpty
            let isMenuItem = role == "AXMenuItem" || role == "AXMenuBarItem"

            if isActionable || isMenuItem {
                // For menu items, use title or role as fallback label
                let displayLabel: String
                if !label.isEmpty {
                    displayLabel = label
                } else if role == "AXMenuItem" {
                    // Try to get any identifier that might help
                    displayLabel = getIdentifier(of: element) ?? "•"
                } else {
                    displayLabel = "•"
                }

                let actionable = ActionableElement(
                    axElement: element,
                    role: role,
                    label: displayLabel,
                    frame: frame,
                    actions: actions,
                    identifier: getIdentifier(of: element)
                )
                results.append(actionable)
            }
        }

        // Traverse children (for submenus)
        let children = getChildren(of: element)
        for child in children {
            results.append(contentsOf: traverseMenuElements(from: child, maxDepth: maxDepth, currentDepth: currentDepth + 1))
        }

        return results
    }

    /// Get open menu items (dropdown menus that are currently visible)
    /// In macOS, open menus can be exposed as children of the focused UI element
    /// or as separate AXMenu windows
    func getOpenMenuItems(from app: AXUIElement) -> [ActionableElement] {
        var results: [ActionableElement] = []

        // Method 1: Check the focused UI element - open menus often appear as focused
        if let axFocused = AXHelpers.getElement(from: app, attribute: kAXFocusedUIElementAttribute as CFString) {
            // Check if the focused element is a menu or has menu children
            if let role = getRole(of: axFocused) {
                if role == "AXMenu" || role == "AXMenuItem" {
                    results.append(contentsOf: traverseMenuElements(from: axFocused))
                }

                // Also check parent - menu items have the menu as parent
                if let parent = AXHelpers.getElement(from: axFocused, attribute: kAXParentAttribute as CFString) {
                    if let parentRole = getRole(of: parent), parentRole == "AXMenu" {
                        results.append(contentsOf: traverseMenuElements(from: parent))
                    }
                }
            }
        }

        // Method 2: Check all windows - menus can appear as popup windows
        var windowsRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &windowsRef) == .success,
           let windows = windowsRef as? [AXUIElement] {
            for window in windows {
                if let role = getRole(of: window) {
                    // Some apps expose menus as windows with specific subroles
                    var subroleRef: CFTypeRef?
                    if AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleRef) == .success,
                       let subrole = subroleRef as? String {
                        if subrole == "AXMenu" || role == "AXMenu" {
                            results.append(contentsOf: traverseMenuElements(from: window))
                        }
                    }
                }

                // Also traverse window children looking for AXMenu elements
                let children = getChildren(of: window)
                for child in children {
                    if let childRole = getRole(of: child), childRole == "AXMenu" {
                        results.append(contentsOf: traverseMenuElements(from: child))
                    }
                }
            }
        }

        return results
    }

    /// Get menu bar extras (system tray items like Wi-Fi, battery, etc.)
    func getMenuBarExtras() -> [ActionableElement] {
        var results: [ActionableElement] = []
        let runningApps = NSWorkspace.shared.runningApplications

        for app in runningApps {
            let axApp = AXUIElementCreateApplication(app.processIdentifier)

            // Set a short timeout for extras - non-responsive apps shouldn't block us
            AXUIElementSetMessagingTimeout(axApp, 0.05)

            guard let extrasMenuBar = getExtrasMenuBar(from: axApp) else { continue }
            let children = getChildren(of: extrasMenuBar)

            for element in children {
                guard let role = getRole(of: element),
                      let frame = getFrame(of: element),
                      frame.width > 0, frame.height > 0 else { continue }

                let label = getLabel(of: element)
                let actions = getActions(of: element)

                let actionable = ActionableElement(
                    axElement: element,
                    role: role,
                    label: label.isEmpty ? "Extra" : label,
                    frame: frame,
                    actions: actions,
                    identifier: getIdentifier(of: element)
                )
                results.append(actionable)
            }
        }

        return results
    }

    /// Get notification center items
    func getNotificationCenterItems() -> [ActionableElement] {
        guard let notificationApp = NSWorkspace.shared.runningApplications
            .first(where: { $0.bundleIdentifier == "com.apple.notificationcenterui" }) else {
            return []
        }

        let axApp = AXUIElementCreateApplication(notificationApp.processIdentifier)

        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let windows = windowsRef as? [AXUIElement] else {
            return []
        }

        var results: [ActionableElement] = []
        for window in windows {
            results.append(contentsOf: traverseElements(from: window))
        }

        return results
    }

    func traverseElements(
        from element: AXUIElement,
        maxDepth: Int = 20,
        currentDepth: Int = 0
    ) -> [ActionableElement] {
        guard currentDepth < maxDepth else { return [] }

        var results: [ActionableElement] = []

        // Check if this element is actionable
        if let role = getRole(of: element),
           let frame = getFrame(of: element),
           frame.width > 0, frame.height > 0,
           isEnabled(element: element) {

            let actions = getActions(of: element)
            let label = getLabel(of: element)
            let identifier = getIdentifier(of: element)

            let isClickable = !actions.isEmpty || isClickableRole(role)

            if isClickable && !label.isEmpty {
                let actionable = ActionableElement(
                    axElement: element,
                    role: role,
                    label: label,
                    frame: frame,
                    actions: actions,
                    identifier: identifier
                )
                results.append(actionable)
            }
        }

        // Traverse children
        let children = getChildren(of: element)
        for child in children {
            results.append(contentsOf: traverseElements(
                from: child,
                maxDepth: maxDepth,
                currentDepth: currentDepth + 1
            ))
        }

        return results
    }
}
