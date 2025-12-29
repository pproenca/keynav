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
        var windowRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute as CFString, &windowRef)
        guard result == .success else { return nil }
        return (windowRef as! AXUIElement)
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
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?

        guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionRef) == .success,
              AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeRef) == .success else {
            return nil
        }

        var position = CGPoint.zero
        var size = CGSize.zero

        AXValueGetValue(positionRef as! AXValue, .cgPoint, &position)
        AXValueGetValue(sizeRef as! AXValue, .cgSize, &size)

        return CGRect(origin: position, size: size)
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
