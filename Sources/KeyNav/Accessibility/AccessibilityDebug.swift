// Sources/KeyNav/Accessibility/AccessibilityDebug.swift
import ApplicationServices
import AppKit

/// Debug utility to print the accessibility hierarchy
final class AccessibilityDebug {

    static func printFocusedElementHierarchy() {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            print("DEBUG: No frontmost application")
            return
        }

        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        print("DEBUG: Frontmost app: \(app.localizedName ?? "unknown")")

        // Check focused window
        var focusedWindowRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &focusedWindowRef) == .success {
            let focusedWindow = focusedWindowRef as! AXUIElement
            let role = getRole(of: focusedWindow) ?? "unknown"
            let title = getTitle(of: focusedWindow) ?? "no title"
            print("DEBUG: Focused 'window' role=\(role), title=\(title)")

            print("DEBUG: --- Focused window children ---")
            printElementTree(focusedWindow, indent: 0, maxDepth: 5)
        } else {
            print("DEBUG: No focused window")
        }

        // Check focused UI element
        var focusedElementRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(axApp, kAXFocusedUIElementAttribute as CFString, &focusedElementRef) == .success {
            let focusedElement = focusedElementRef as! AXUIElement
            let role = getRole(of: focusedElement) ?? "unknown"
            let title = getTitle(of: focusedElement) ?? "no title"
            print("DEBUG: Focused UI element role=\(role), title=\(title)")
        } else {
            print("DEBUG: No focused UI element")
        }

        // Check menu bar
        var menuBarRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(axApp, kAXMenuBarAttribute as CFString, &menuBarRef) == .success {
            let menuBar = menuBarRef as! AXUIElement
            print("DEBUG: --- Menu bar children ---")
            let children = getChildren(of: menuBar)
            for child in children {
                let role = getRole(of: child) ?? "unknown"
                let title = getTitle(of: child) ?? "no title"
                let actions = getActions(of: child)
                print("DEBUG:   MenuBarItem role=\(role), title=\(title), actions=\(actions)")

                // Check for open menu (children of menu bar item)
                let menuChildren = getChildren(of: child)
                if !menuChildren.isEmpty {
                    print("DEBUG:     Has \(menuChildren.count) children (menu might be open):")
                    for menuChild in menuChildren.prefix(10) {
                        let childRole = getRole(of: menuChild) ?? "unknown"
                        let childTitle = getTitle(of: menuChild) ?? "no title"
                        let childActions = getActions(of: menuChild)
                        print("DEBUG:       role=\(childRole), title=\(childTitle), actions=\(childActions)")

                        // One more level for menu items
                        let subChildren = getChildren(of: menuChild)
                        for subChild in subChildren.prefix(5) {
                            let subRole = getRole(of: subChild) ?? "unknown"
                            let subTitle = getTitle(of: subChild) ?? "no title"
                            let subActions = getActions(of: subChild)
                            print("DEBUG:         role=\(subRole), title=\(subTitle), actions=\(subActions)")
                        }
                    }
                }
            }
        }
    }

    private static func printElementTree(_ element: AXUIElement, indent: Int, maxDepth: Int) {
        guard indent < maxDepth else { return }

        let indentStr = String(repeating: "  ", count: indent)
        let role = getRole(of: element) ?? "unknown"
        let title = getTitle(of: element) ?? ""
        let actions = getActions(of: element)
        let frame = getFrame(of: element)
        let frameStr = frame.map { "(\(Int($0.origin.x)),\(Int($0.origin.y)) \(Int($0.width))x\(Int($0.height)))" } ?? "no frame"

        print("DEBUG: \(indentStr)[\(role)] '\(title)' actions=\(actions) frame=\(frameStr)")

        let children = getChildren(of: element)
        for child in children.prefix(10) {
            printElementTree(child, indent: indent + 1, maxDepth: maxDepth)
        }
        if children.count > 10 {
            print("DEBUG: \(indentStr)  ... and \(children.count - 10) more children")
        }
    }

    private static func getRole(of element: AXUIElement) -> String? {
        var roleRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef) == .success else { return nil }
        return roleRef as? String
    }

    private static func getTitle(of element: AXUIElement) -> String? {
        var titleRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &titleRef) == .success,
           let title = titleRef as? String, !title.isEmpty {
            return title
        }
        var descRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXDescriptionAttribute as CFString, &descRef) == .success,
           let desc = descRef as? String, !desc.isEmpty {
            return desc
        }
        return nil
    }

    private static func getChildren(of element: AXUIElement) -> [AXUIElement] {
        var childrenRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenRef) == .success,
              let children = childrenRef as? [AXUIElement] else { return [] }
        return children
    }

    private static func getActions(of element: AXUIElement) -> [String] {
        var actionsRef: CFArray?
        guard AXUIElementCopyActionNames(element, &actionsRef) == .success,
              let actions = actionsRef as? [String] else { return [] }
        return actions
    }

    private static func getFrame(of element: AXUIElement) -> CGRect? {
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionRef) == .success,
              AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeRef) == .success else { return nil }

        var position = CGPoint.zero
        var size = CGSize.zero
        AXValueGetValue(positionRef as! AXValue, .cgPoint, &position)
        AXValueGetValue(sizeRef as! AXValue, .cgSize, &size)
        return CGRect(origin: position, size: size)
    }
}
