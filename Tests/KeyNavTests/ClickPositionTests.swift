// Tests/KeyNavTests/ClickPositionTests.swift
import XCTest
@testable import KeyNav

final class ClickPositionTests: XCTestCase {

    // MARK: - Click Position Calculator Tests

    func testRegularElementClicksAtCenter() {
        let element = ActionableElement(
            role: "AXButton",
            label: "Submit",
            frame: CGRect(x: 100, y: 100, width: 100, height: 50),
            actions: ["AXPress"],
            identifier: nil
        )

        let position = ClickPositionCalculator.clickPosition(for: element)

        XCTAssertEqual(position.x, 150, "Should click at horizontal center")
        XCTAssertEqual(position.y, 125, "Should click at vertical center")
    }

    func testLinkElementClicksAtBottomLeft() {
        let element = ActionableElement(
            role: "AXLink",
            label: "Click here",
            frame: CGRect(x: 100, y: 100, width: 100, height: 50),
            actions: ["AXPress"],
            identifier: nil
        )

        let position = ClickPositionCalculator.clickPosition(for: element)

        // Bottom-left with 5px offset
        XCTAssertEqual(position.x, 105, "Should click at left + 5px offset")
        XCTAssertEqual(position.y, 145, "Should click at bottom - 5px offset")
    }

    func testStaticTextElementClicksAtBottomLeft() {
        // Static text elements sometimes act as links
        let element = ActionableElement(
            role: "AXStaticText",
            label: "Link text",
            frame: CGRect(x: 200, y: 200, width: 80, height: 20),
            actions: ["AXPress"],
            identifier: nil
        )

        let position = ClickPositionCalculator.clickPosition(for: element)

        // Bottom-left with 5px offset
        XCTAssertEqual(position.x, 205, "Should click at left + 5px offset")
        XCTAssertEqual(position.y, 215, "Should click at bottom - 5px offset")
    }

    func testMenuItemClicksAtCenter() {
        let element = ActionableElement(
            role: "AXMenuItem",
            label: "File",
            frame: CGRect(x: 50, y: 50, width: 60, height: 22),
            actions: ["AXPress"],
            identifier: nil
        )

        let position = ClickPositionCalculator.clickPosition(for: element)

        XCTAssertEqual(position.x, 80, "Menu items should click at center")
        XCTAssertEqual(position.y, 61, "Menu items should click at center")
    }

    func testCheckboxClicksAtCenter() {
        let element = ActionableElement(
            role: "AXCheckBox",
            label: "Accept terms",
            frame: CGRect(x: 100, y: 300, width: 150, height: 20),
            actions: ["AXPress"],
            identifier: nil
        )

        let position = ClickPositionCalculator.clickPosition(for: element)

        XCTAssertEqual(position.x, 175, "Checkboxes should click at center")
        XCTAssertEqual(position.y, 310, "Checkboxes should click at center")
    }

    func testSmallLinkStillUsesOffset() {
        // Even small links should use the offset if possible
        let element = ActionableElement(
            role: "AXLink",
            label: "X",
            frame: CGRect(x: 100, y: 100, width: 15, height: 15),
            actions: ["AXPress"],
            identifier: nil
        )

        let position = ClickPositionCalculator.clickPosition(for: element)

        // With small elements, offset should be clamped to stay within bounds
        XCTAssertGreaterThanOrEqual(position.x, 100)
        XCTAssertLessThanOrEqual(position.x, 115)
        XCTAssertGreaterThanOrEqual(position.y, 100)
        XCTAssertLessThanOrEqual(position.y, 115)
    }
}
