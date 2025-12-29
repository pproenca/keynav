// Tests/KeyNavTests/FuzzyMatcherTests.swift
import XCTest
@testable import KeyNav

final class FuzzyMatcherTests: XCTestCase {

    func testExactMatch() {
        let matcher = FuzzyMatcher()
        XCTAssertTrue(matcher.matches(query: "Save", in: "Save"))
    }

    func testCaseInsensitiveMatch() {
        let matcher = FuzzyMatcher()
        XCTAssertTrue(matcher.matches(query: "save", in: "Save Document"))
    }

    func testSubstringMatch() {
        let matcher = FuzzyMatcher()
        XCTAssertTrue(matcher.matches(query: "doc", in: "Save Document"))
    }

    func testNoMatch() {
        let matcher = FuzzyMatcher()
        XCTAssertFalse(matcher.matches(query: "xyz", in: "Save Document"))
    }

    func testEmptyQuery() {
        let matcher = FuzzyMatcher()
        XCTAssertTrue(matcher.matches(query: "", in: "Anything"))
    }

    func testMatchRange() {
        let matcher = FuzzyMatcher()
        let range = matcher.matchRange(query: "Doc", in: "Save Document")

        XCTAssertNotNil(range)
        XCTAssertEqual(range?.lowerBound, "Save Document".index("Save Document".startIndex, offsetBy: 5))
    }

    func testFilterElements() {
        let matcher = FuzzyMatcher()
        let elements = [
            ActionableElement(role: "AXButton", label: "Save", frame: .zero, actions: ["AXPress"], identifier: nil),
            ActionableElement(role: "AXButton", label: "Open", frame: .zero, actions: ["AXPress"], identifier: nil),
            ActionableElement(role: "AXButton", label: "Save As", frame: .zero, actions: ["AXPress"], identifier: nil)
        ]

        let filtered = matcher.filter(elements: elements, query: "save")

        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered[0].label, "Save")
        XCTAssertEqual(filtered[1].label, "Save As")
    }
}
