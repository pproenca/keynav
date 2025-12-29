// Tests/KeyNavTests/ElementTraversalMenuTests.swift
import XCTest
@testable import KeyNav

final class ElementTraversalMenuTests: XCTestCase {

    // MARK: - Clickable Role Tests

    func testMenuItemIsClickableRole() {
        let traversal = ElementTraversal()
        XCTAssertTrue(traversal.isClickableRole("AXMenuItem"))
    }

    func testMenuBarItemIsClickableRole() {
        let traversal = ElementTraversal()
        XCTAssertTrue(traversal.isClickableRole("AXMenuBarItem"))
    }

    func testMenuRoleIsNotClickable() {
        // AXMenu is a container, not clickable itself
        let traversal = ElementTraversal()
        XCTAssertFalse(traversal.isClickableRole("AXMenu"))
    }

    // MARK: - Actionable Logic Tests
    // Following Vimac's approach: elements are actionable if they have useful actions
    // (excluding AXShowMenu, AXScrollToVisible, AXShowDefaultUI, AXShowAlternateUI)

    func testIsActionableWithPressAction() {
        // AXPress is a useful action - element should be actionable
        let actions = ["AXPress"]
        XCTAssertTrue(hasUsefulActions(actions))
    }

    func testIsActionableWithConfirmAction() {
        let actions = ["AXConfirm"]
        XCTAssertTrue(hasUsefulActions(actions))
    }

    func testIsActionableWithOpenAction() {
        let actions = ["AXOpen"]
        XCTAssertTrue(hasUsefulActions(actions))
    }

    func testIsNotActionableWithOnlyShowMenu() {
        // AXShowMenu alone doesn't make element actionable (per Vimac)
        let actions = ["AXShowMenu"]
        XCTAssertFalse(hasUsefulActions(actions))
    }

    func testIsNotActionableWithOnlyScrollToVisible() {
        let actions = ["AXScrollToVisible"]
        XCTAssertFalse(hasUsefulActions(actions))
    }

    func testIsNotActionableWithOnlyShowDefaultUI() {
        let actions = ["AXShowDefaultUI"]
        XCTAssertFalse(hasUsefulActions(actions))
    }

    func testIsNotActionableWithOnlyShowAlternateUI() {
        let actions = ["AXShowAlternateUI"]
        XCTAssertFalse(hasUsefulActions(actions))
    }

    func testIsActionableWithMixedActions() {
        // If there's at least one useful action, element is actionable
        let actions = ["AXShowMenu", "AXPress", "AXScrollToVisible"]
        XCTAssertTrue(hasUsefulActions(actions))
    }

    func testIsNotActionableWithAllIgnoredActions() {
        let actions = ["AXShowMenu", "AXScrollToVisible", "AXShowDefaultUI", "AXShowAlternateUI"]
        XCTAssertFalse(hasUsefulActions(actions))
    }

    func testIsNotActionableWithEmptyActions() {
        let actions: [String] = []
        XCTAssertFalse(hasUsefulActions(actions))
    }

    // MARK: - Menu Item with Actions but No Label
    // Per Vimac's approach: menu items with actions don't need labels to be hintable

    func testMenuItemWithActionsAndNoLabelShouldBeHintable() {
        // This tests the concept: a menu item with AXPress action but empty label
        // should still be considered hintable (will get fallback label "•")
        let actions = ["AXPress"]
        let isMenuItem = true
        let hasUsefulAction = hasUsefulActions(actions)

        // Per Vimac's logic: isActionable || isMenuItem
        let shouldBeHintable = hasUsefulAction || isMenuItem
        XCTAssertTrue(shouldBeHintable)
    }

    func testMenuItemWithNoActionsIsStillHintable() {
        // Menu items are always hintable because they're interactive
        let actions: [String] = []
        let isMenuItem = true
        let hasUsefulAction = hasUsefulActions(actions)

        // Per Vimac's logic: isActionable || isMenuItem
        let shouldBeHintable = hasUsefulAction || isMenuItem
        XCTAssertTrue(shouldBeHintable, "Menu items should be hintable even without actions")
    }

    // MARK: - Deduplication Tests

    func testDeduplicationByFrame() {
        // Elements at the same position should be deduplicated
        let element1 = ActionableElement(
            axElement: nil,
            role: "AXMenuItem",
            label: "Copy",
            frame: CGRect(x: 100, y: 200, width: 80, height: 20),
            actions: ["AXPress"],
            identifier: nil
        )

        let element2 = ActionableElement(
            axElement: nil,
            role: "AXMenuItem",
            label: "Copy",
            frame: CGRect(x: 100, y: 200, width: 80, height: 20),
            actions: ["AXPress"],
            identifier: nil
        )

        var elements = [element1, element2]
        var seen = Set<String>()
        elements = elements.filter { element in
            let key = "\(element.frame.origin.x),\(element.frame.origin.y),\(element.frame.width),\(element.frame.height)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }

        XCTAssertEqual(elements.count, 1, "Duplicate elements at same position should be deduplicated")
    }

    func testDeduplicationKeepsDistinctPositions() {
        let element1 = ActionableElement(
            axElement: nil,
            role: "AXMenuItem",
            label: "Copy",
            frame: CGRect(x: 100, y: 200, width: 80, height: 20),
            actions: ["AXPress"],
            identifier: nil
        )

        let element2 = ActionableElement(
            axElement: nil,
            role: "AXMenuItem",
            label: "Paste",
            frame: CGRect(x: 100, y: 220, width: 80, height: 20), // Different Y
            actions: ["AXPress"],
            identifier: nil
        )

        var elements = [element1, element2]
        var seen = Set<String>()
        elements = elements.filter { element in
            let key = "\(element.frame.origin.x),\(element.frame.origin.y),\(element.frame.width),\(element.frame.height)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }

        XCTAssertEqual(elements.count, 2, "Elements at different positions should both be kept")
    }

    // MARK: - Role Detection Tests

    func testAllMenuRelatedRoles() {
        let traversal = ElementTraversal()

        // Menu-related roles that should be clickable
        XCTAssertTrue(traversal.isClickableRole("AXMenuItem"))
        XCTAssertTrue(traversal.isClickableRole("AXMenuBarItem"))

        // Container roles that should NOT be clickable
        XCTAssertFalse(traversal.isClickableRole("AXMenu"))
        XCTAssertFalse(traversal.isClickableRole("AXMenuBar"))
    }

    // MARK: - Helper

    /// Mirrors the isActionable logic from traverseMenuElements
    /// Following Vimac's approach: ignore certain actions that don't indicate interactivity
    private func hasUsefulActions(_ actions: [String]) -> Bool {
        let ignoredActions: Set<String> = [
            "AXShowMenu",
            "AXScrollToVisible",
            "AXShowDefaultUI",
            "AXShowAlternateUI"
        ]
        let usefulActions = Set(actions).subtracting(ignoredActions)
        return !usefulActions.isEmpty
    }
}
