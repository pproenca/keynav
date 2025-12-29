// Tests/KeyNavTests/ElementTraversalTests.swift
import XCTest
@testable import KeyNav

final class ElementTraversalTests: XCTestCase {

    func testClickableRoles() {
        let traversal = ElementTraversal()

        XCTAssertTrue(traversal.isClickableRole("AXButton"))
        XCTAssertTrue(traversal.isClickableRole("AXLink"))
        XCTAssertTrue(traversal.isClickableRole("AXCheckBox"))
        XCTAssertTrue(traversal.isClickableRole("AXMenuItem"))
        XCTAssertFalse(traversal.isClickableRole("AXStaticText"))
        XCTAssertFalse(traversal.isClickableRole("AXGroup"))
    }
}
