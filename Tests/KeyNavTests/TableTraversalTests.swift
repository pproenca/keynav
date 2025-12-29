// Tests/KeyNavTests/TableTraversalTests.swift
import XCTest
@testable import KeyNav

final class TableTraversalTests: XCTestCase {

    // MARK: - Table Role Detection

    func testTableRolesIdentified() {
        let optimizer = TableTraversalOptimizer()

        XCTAssertTrue(optimizer.isTableRole("AXTable"))
        XCTAssertTrue(optimizer.isTableRole("AXOutline"))
        XCTAssertFalse(optimizer.isTableRole("AXScrollArea"))
        XCTAssertFalse(optimizer.isTableRole("AXList"))
    }

    // MARK: - Visible Rows Strategy

    func testUseVisibleRowsForTables() {
        let optimizer = TableTraversalOptimizer()

        XCTAssertTrue(optimizer.shouldUseVisibleRows(for: "AXTable"))
        XCTAssertTrue(optimizer.shouldUseVisibleRows(for: "AXOutline"))
        XCTAssertFalse(optimizer.shouldUseVisibleRows(for: "AXScrollArea"))
    }

    // MARK: - Mock Row Filtering

    struct MockRow {
        let identifier: String
        let isVisible: Bool
    }

    func testFilterVisibleRows() {
        let optimizer = TableTraversalOptimizer()

        let allRows = [
            MockRow(identifier: "1", isVisible: true),
            MockRow(identifier: "2", isVisible: false),
            MockRow(identifier: "3", isVisible: true),
            MockRow(identifier: "4", isVisible: false),
            MockRow(identifier: "5", isVisible: true)
        ]

        let visibleRows = optimizer.filterVisible(allRows, isVisible: { $0.isVisible })

        XCTAssertEqual(visibleRows.count, 3)
        XCTAssertEqual(visibleRows[0].identifier, "1")
        XCTAssertEqual(visibleRows[1].identifier, "3")
        XCTAssertEqual(visibleRows[2].identifier, "5")
    }

    // MARK: - Performance Optimization

    func testVisibleRowsAttribute() {
        // Document the AXVisibleRows attribute usage
        let optimizer = TableTraversalOptimizer()

        // The attribute name for visible rows
        XCTAssertEqual(optimizer.visibleRowsAttribute, "AXVisibleRows")
    }

    func testVisibleChildrenAttribute() {
        let optimizer = TableTraversalOptimizer()

        // Alternative attribute for visible children
        XCTAssertEqual(optimizer.visibleChildrenAttribute, "AXVisibleChildren")
    }

    // MARK: - Outline Expansion State

    func testOutlineExpandedAttribute() {
        let optimizer = TableTraversalOptimizer()

        // Attribute for checking if outline row is expanded
        XCTAssertEqual(optimizer.expandedAttribute, "AXExpanded")
    }

    func testOutlineDisclosedRowsAttribute() {
        let optimizer = TableTraversalOptimizer()

        // Attribute for disclosed (visible) rows in outline
        XCTAssertEqual(optimizer.disclosedRowsAttribute, "AXDisclosedRows")
    }
}
