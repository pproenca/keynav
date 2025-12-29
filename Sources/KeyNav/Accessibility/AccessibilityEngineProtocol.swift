// Sources/KeyNav/Accessibility/AccessibilityEngineProtocol.swift
import Foundation

/// Protocol for accessibility engine to enable testing with mocks
protocol AccessibilityEngineProtocol {
    func getActionableElements(completion: @escaping ([ActionableElement]) -> Void)
    func getActionableElementsSync() -> [ActionableElement]
    func performClick(on element: ActionableElement)
    func performDoubleClick(on element: ActionableElement)
    func performRightClick(on element: ActionableElement)
}

// Make AccessibilityEngine conform to the protocol
extension AccessibilityEngine: AccessibilityEngineProtocol {}

/// Mock accessibility engine for testing
final class MockAccessibilityEngine: AccessibilityEngineProtocol {
    var mockElements: [ActionableElement] = []
    var clickedElements: [ActionableElement] = []
    var doubleClickedElements: [ActionableElement] = []
    var rightClickedElements: [ActionableElement] = []

    func getActionableElements(completion: @escaping ([ActionableElement]) -> Void) {
        completion(mockElements)
    }

    func getActionableElementsSync() -> [ActionableElement] {
        return mockElements
    }

    func performClick(on element: ActionableElement) {
        clickedElements.append(element)
    }

    func performDoubleClick(on element: ActionableElement) {
        doubleClickedElements.append(element)
    }

    func performRightClick(on element: ActionableElement) {
        rightClickedElements.append(element)
    }
}
