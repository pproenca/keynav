import AppKit
// Sources/KeyNav/Accessibility/ElementTraversal.swift
import ApplicationServices

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
        "AXTabGroup",
    ]

    private lazy var menuTraversal = MenuTraversal(traversal: self)
    private lazy var menuBarExtrasTraversal = MenuBarExtrasTraversal(traversal: self)

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
        if let title = getStringAttribute(kAXTitleAttribute, from: element), !title.isEmpty {
            return title
        }
        // Try AXDescription
        if let desc = getStringAttribute(kAXDescriptionAttribute, from: element), !desc.isEmpty {
            return desc
        }
        // Try AXValue
        if let value = getStringAttribute(kAXValueAttribute, from: element), !value.isEmpty {
            return value
        }
        return ""
    }

    private func getStringAttribute(_ attribute: String, from element: AXUIElement) -> String? {
        var ref: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, attribute as CFString, &ref) == .success {
            return ref as? String
        }
        return nil
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
        guard result == .success else { return true }  // Assume enabled if attribute missing
        return (enabledRef as? Bool) ?? true
    }

    /// Get menu bar items from the frontmost app (File, Edit, View, etc.)
    /// Also traverses into any open menus to get their menu items
    func getMenuBarItems(from app: AXUIElement) -> [ActionableElement] {
        guard let menuBar = getMenuBar(from: app) else { return [] }
        let menuBarItems = getChildren(of: menuBar)

        var results: [ActionableElement] = []

        for menuBarItem in menuBarItems {
            if let actionable = createMenuBarItemActionable(from: menuBarItem) {
                results.append(actionable)
            }

            // Traverse into children (open menu items) if any exist
            let menuChildren = getChildren(of: menuBarItem)
            for menuChild in menuChildren {
                results.append(contentsOf: traverseMenuElements(from: menuChild))
            }
        }

        return results
    }

    private func createMenuBarItemActionable(from element: AXUIElement) -> ActionableElement? {
        guard let role = getRole(of: element),
            let frame = getFrame(of: element),
            frame.width > 0, frame.height > 0
        else {
            return nil
        }

        let label = getLabel(of: element)
        let actions = getActions(of: element)

        return ActionableElement(
            axElement: element,
            role: role,
            label: label.isEmpty ? "Menu" : label,
            frame: frame,
            actions: actions,
            identifier: getIdentifier(of: element)
        )
    }

    /// Find the root menu element and traverse all its items
    func traverseFromMenuRoot(_ element: AXUIElement) -> [ActionableElement] {
        let rootElement = findMenuRoot(from: element)
        return traverseMenuElements(from: rootElement)
    }

    private func findMenuRoot(from element: AXUIElement) -> AXUIElement {
        var current = element
        var visited = Set<String>()

        while true {
            let elementDesc = String(describing: current)
            if visited.contains(elementDesc) { break }
            visited.insert(elementDesc)

            guard let parent = AXHelpers.getElement(from: current, attribute: kAXParentAttribute as CFString) else {
                break
            }

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
        }

        return current
    }

    /// Recursively traverse menu elements (handles nested submenus)
    func traverseMenuElements(
        from element: AXUIElement,
        maxDepth: Int = 10,
        currentDepth: Int = 0
    ) -> [ActionableElement] {
        guard currentDepth < maxDepth else { return [] }

        var results: [ActionableElement] = []

        guard let role = getRole(of: element) else {
            return traverseChildMenuElements(from: element, maxDepth: maxDepth, currentDepth: currentDepth)
        }

        // Skip the menu container itself but process its children
        if role == "AXMenu" {
            return traverseChildMenuElements(from: element, maxDepth: maxDepth, currentDepth: currentDepth)
        }

        // Try to create actionable element from this menu item
        if let actionable = createMenuActionable(from: element, role: role) {
            results.append(actionable)
        }

        // Traverse children (for submenus)
        let childElements = traverseChildMenuElements(
            from: element,
            maxDepth: maxDepth,
            currentDepth: currentDepth
        )
        results.append(contentsOf: childElements)

        return results
    }

    private func traverseChildMenuElements(
        from element: AXUIElement,
        maxDepth: Int,
        currentDepth: Int
    ) -> [ActionableElement] {
        var results: [ActionableElement] = []
        let children = getChildren(of: element)
        for child in children {
            let subResults = traverseMenuElements(from: child, maxDepth: maxDepth, currentDepth: currentDepth + 1)
            results.append(contentsOf: subResults)
        }
        return results
    }

    private func createMenuActionable(from element: AXUIElement, role: String) -> ActionableElement? {
        guard let frame = getFrame(of: element),
            frame.width > 0, frame.height > 0
        else {
            return nil
        }

        let label = getLabel(of: element)
        let actions = getActions(of: element)

        // Check if element is actionable
        let ignoredActions: Set<String> = [
            "AXShowMenu", "AXScrollToVisible", "AXShowDefaultUI", "AXShowAlternateUI",
        ]
        let usefulActions = Set(actions).subtracting(ignoredActions)

        let isActionable = !usefulActions.isEmpty
        let isMenuItem = role == "AXMenuItem" || role == "AXMenuBarItem"

        guard isActionable || isMenuItem else { return nil }

        // For menu items, use title or role as fallback label
        let displayLabel = determineMenuItemLabel(label: label, role: role, element: element)

        return ActionableElement(
            axElement: element,
            role: role,
            label: displayLabel,
            frame: frame,
            actions: actions,
            identifier: getIdentifier(of: element)
        )
    }

    private func determineMenuItemLabel(label: String, role: String, element: AXUIElement) -> String {
        if !label.isEmpty {
            return label
        }
        if role == "AXMenuItem" {
            return getIdentifier(of: element) ?? "•"
        }
        return "•"
    }

    /// Get open menu items (dropdown menus that are currently visible)
    func getOpenMenuItems(from app: AXUIElement) -> [ActionableElement] {
        return menuTraversal.findOpenMenus(from: app)
    }

    /// Get menu bar extras (system tray items like Wi-Fi, battery, etc.)
    func getMenuBarExtras() -> [ActionableElement] {
        return menuBarExtrasTraversal.findMenuBarExtras()
    }

    /// Get notification center items
    func getNotificationCenterItems() -> [ActionableElement] {
        guard
            let notificationApp = NSWorkspace.shared.runningApplications
                .first(where: { $0.bundleIdentifier == "com.apple.notificationcenterui" })
        else {
            return []
        }

        let axApp = AXUIElementCreateApplication(notificationApp.processIdentifier)

        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef) == .success,
            let windows = windowsRef as? [AXUIElement]
        else {
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
        if let actionable = createActionableElement(from: element) {
            results.append(actionable)
        }

        // Traverse children
        let children = getChildren(of: element)
        for child in children {
            results.append(
                contentsOf: traverseElements(
                    from: child,
                    maxDepth: maxDepth,
                    currentDepth: currentDepth + 1
                ))
        }

        return results
    }

    private func createActionableElement(from element: AXUIElement) -> ActionableElement? {
        guard let role = getRole(of: element),
            let frame = getFrame(of: element),
            frame.width > 0, frame.height > 0,
            isEnabled(element: element)
        else {
            return nil
        }

        let actions = getActions(of: element)
        let label = getLabel(of: element)
        let identifier = getIdentifier(of: element)

        let isClickable = !actions.isEmpty || isClickableRole(role)

        guard isClickable && !label.isEmpty else { return nil }

        return ActionableElement(
            axElement: element,
            role: role,
            label: label,
            frame: frame,
            actions: actions,
            identifier: identifier
        )
    }
}
