import AppKit
// Sources/KeyNav/Accessibility/MenuBarExtrasTraversal.swift
import ApplicationServices

/// Helper class for traversing menu bar extras (system tray items)
/// Separates menu bar extras logic from ElementTraversal
final class MenuBarExtrasTraversal {

    private let traversal: ElementTraversal

    init(traversal: ElementTraversal) {
        self.traversal = traversal
    }

    /// Get menu bar extras (system tray items like Wi-Fi, battery, etc.)
    func findMenuBarExtras() -> [ActionableElement] {
        var results: [ActionableElement] = []
        let runningApps = NSWorkspace.shared.runningApplications

        for app in runningApps {
            results.append(contentsOf: findExtrasForApp(app))
        }

        return results
    }

    private func findExtrasForApp(_ app: NSRunningApplication) -> [ActionableElement] {
        var results: [ActionableElement] = []

        let axApp = AXUIElementCreateApplication(app.processIdentifier)

        // Set a short timeout for extras - non-responsive apps shouldn't block us
        AXUIElementSetMessagingTimeout(axApp, 0.05)

        guard let extrasMenuBar = traversal.getExtrasMenuBar(from: axApp) else {
            return results
        }

        let children = traversal.getChildren(of: extrasMenuBar)

        for element in children {
            if let actionable = createActionableElement(from: element) {
                results.append(actionable)
            }
        }

        return results
    }

    private func createActionableElement(from element: AXUIElement) -> ActionableElement? {
        guard let role = traversal.getRole(of: element),
            let frame = traversal.getFrame(of: element),
            frame.width > 0, frame.height > 0
        else {
            return nil
        }

        let label = traversal.getLabel(of: element)
        let actions = traversal.getActions(of: element)

        return ActionableElement(
            axElement: element,
            role: role,
            label: label.isEmpty ? "Extra" : label,
            frame: frame,
            actions: actions,
            identifier: traversal.getIdentifier(of: element)
        )
    }
}
