// Sources/KeyNav/Accessibility/AccessibilityEngine.swift
import ApplicationServices
import AppKit

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
        guard let app = traversal.getFrontmostApplication() else { return [] }
        guard let window = traversal.getFocusedWindow(from: app) else { return [] }

        return traversal.traverseElements(from: window)
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
                      let windows = windowsRef as? [AXUIElement] else { continue }

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
            // Fallback: simulate mouse click at element center
            let center = CGPoint(
                x: element.frame.midX,
                y: element.frame.midY
            )
            simulateClick(at: center)
        }
    }

    func performDoubleClick(on element: ActionableElement) {
        let center = CGPoint(x: element.frame.midX, y: element.frame.midY)
        simulateClick(at: center, clickCount: 2)
    }

    func performRightClick(on element: ActionableElement) {
        let center = CGPoint(x: element.frame.midX, y: element.frame.midY)
        simulateRightClick(at: center)
    }

    private func simulateClick(at point: CGPoint, clickCount: Int = 1) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)

        mouseDown?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))
        mouseUp?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }

    private func simulateRightClick(at point: CGPoint) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: point, mouseButton: .right)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: point, mouseButton: .right)

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
}
