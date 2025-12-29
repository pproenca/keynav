// Tests/KeyNavTests/ScrollAreaDetectionTests.swift
import XCTest
@testable import KeyNav

final class ScrollAreaDetectionTests: XCTestCase {

    // MARK: - Mock Scroll Area

    struct MockScrollArea: ScrollAreaProtocol {
        let frame: CGRect
        let role: String
        let children: [MockScrollArea]

        var surfaceArea: CGFloat {
            return frame.width * frame.height
        }
    }

    // MARK: - Depth-First Traversal

    func testDepthFirstTraversalFindsScrollAreas() {
        let finder = ScrollAreaFinder()

        let areas: [MockScrollArea] = [
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 100, height: 100), role: "AXScrollArea", children: []),
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 200, height: 200), role: "AXScrollArea", children: [])
        ]

        let result = finder.findScrollAreas(from: areas)

        XCTAssertEqual(result.count, 2)
    }

    func testDepthFirstTraversalSkipsWebAreas() {
        let finder = ScrollAreaFinder()

        let areas: [MockScrollArea] = [
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 100, height: 100), role: "AXWebArea", children: []),
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 200, height: 200), role: "AXScrollArea", children: [])
        ]

        let result = finder.findScrollAreas(from: areas)

        // Should skip the web area
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.role, "AXScrollArea")
    }

    // MARK: - Surface Area Sorting

    func testScrollAreasSortedBySurfaceArea() {
        let finder = ScrollAreaFinder()

        let areas: [MockScrollArea] = [
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 50, height: 50), role: "AXScrollArea", children: []),    // 2500
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 200, height: 200), role: "AXScrollArea", children: []), // 40000
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 100, height: 100), role: "AXScrollArea", children: [])  // 10000
        ]

        let result = finder.findScrollAreas(from: areas)

        // Should be sorted largest first
        XCTAssertEqual(result[0].surfaceArea, 40000)
        XCTAssertEqual(result[1].surfaceArea, 10000)
        XCTAssertEqual(result[2].surfaceArea, 2500)
    }

    // MARK: - Table/Outline Handling

    func testTableRoleIdentified() {
        let finder = ScrollAreaFinder()

        let areas: [MockScrollArea] = [
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 100, height: 100), role: "AXTable", children: []),
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 100, height: 100), role: "AXOutline", children: [])
        ]

        let result = finder.findScrollAreas(from: areas)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.role == "AXTable" })
        XCTAssertTrue(result.contains { $0.role == "AXOutline" })
    }

    func testVisibleRowsForTables() {
        let config = ScrollAreaConfig()

        XCTAssertTrue(config.useVisibleRows(for: "AXTable"))
        XCTAssertTrue(config.useVisibleRows(for: "AXOutline"))
        XCTAssertFalse(config.useVisibleRows(for: "AXScrollArea"))
    }

    // MARK: - Skip Roles

    func testSkipRolesConfiguration() {
        let config = ScrollAreaConfig()

        XCTAssertTrue(config.shouldSkip(role: "AXWebArea"))
        XCTAssertFalse(config.shouldSkip(role: "AXScrollArea"))
        XCTAssertFalse(config.shouldSkip(role: "AXTable"))
    }

    // MARK: - Empty Results

    func testNoScrollAreasReturnsEmpty() {
        let finder = ScrollAreaFinder()

        let areas: [MockScrollArea] = []

        let result = finder.findScrollAreas(from: areas)

        XCTAssertTrue(result.isEmpty)
    }

    func testAllSkippedAreasReturnsEmpty() {
        let finder = ScrollAreaFinder()

        let areas: [MockScrollArea] = [
            MockScrollArea(frame: CGRect(x: 0, y: 0, width: 100, height: 100), role: "AXWebArea", children: [])
        ]

        let result = finder.findScrollAreas(from: areas)

        XCTAssertTrue(result.isEmpty)
    }
}
