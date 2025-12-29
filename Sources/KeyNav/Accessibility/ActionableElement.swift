// Sources/KeyNav/Accessibility/ActionableElement.swift
import Foundation
import ApplicationServices

struct ActionableElement: Equatable {
    let axElement: AXUIElement?
    let role: String
    let label: String
    let frame: CGRect
    let actions: [String]
    let identifier: String?

    init(
        axElement: AXUIElement? = nil,
        role: String,
        label: String,
        frame: CGRect,
        actions: [String],
        identifier: String?
    ) {
        self.axElement = axElement
        self.role = role
        self.label = label
        self.frame = frame
        self.actions = actions
        self.identifier = identifier
    }

    var isClickable: Bool {
        let clickableActions = ["AXPress", "AXConfirm", "AXOpen", "AXPick"]
        return actions.contains { clickableActions.contains($0) }
    }

    var isScrollable: Bool {
        role == "AXScrollArea" || role == "AXScrollBar"
    }

    static func == (lhs: ActionableElement, rhs: ActionableElement) -> Bool {
        lhs.role == rhs.role &&
        lhs.label == rhs.label &&
        lhs.frame == rhs.frame &&
        lhs.actions == rhs.actions &&
        lhs.identifier == rhs.identifier
    }
}
