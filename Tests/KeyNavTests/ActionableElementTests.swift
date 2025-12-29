// Tests/KeyNavTests/ActionableElementTests.swift
import XCTest
@testable import KeyNav

final class ActionableElementTests: XCTestCase {

    func testActionableElementInitialization() {
        let frame = CGRect(x: 100, y: 200, width: 50, height: 30)
        let element = ActionableElement(
            role: "AXButton",
            label: "Submit",
            frame: frame,
            actions: ["AXPress"],
            identifier: "submit-btn"
        )

        XCTAssertEqual(element.role, "AXButton")
        XCTAssertEqual(element.label, "Submit")
        XCTAssertEqual(element.frame, frame)
        XCTAssertEqual(element.actions, ["AXPress"])
        XCTAssertEqual(element.identifier, "submit-btn")
    }

    func testIsClickable() {
        let clickable = ActionableElement(
            role: "AXButton",
            label: "OK",
            frame: .zero,
            actions: ["AXPress"],
            identifier: nil
        )
        XCTAssertTrue(clickable.isClickable)

        let notClickable = ActionableElement(
            role: "AXStaticText",
            label: "Label",
            frame: .zero,
            actions: [],
            identifier: nil
        )
        XCTAssertFalse(notClickable.isClickable)
    }
}
