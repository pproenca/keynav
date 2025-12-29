// Tests/KeyNavTests/SearchPredicateTests.swift
import XCTest
@testable import KeyNav

final class SearchPredicateTests: XCTestCase {

    // MARK: - Mock Elements

    struct MockSearchElement: SearchableElement {
        let identifier: String
        let role: String
        let frame: CGRect

        init(identifier: String = UUID().uuidString, role: String, frame: CGRect = .zero) {
            self.identifier = identifier
            self.role = role
            self.frame = frame
        }
    }

    // MARK: - Available Search Categories

    func testAllSearchCategoriesAvailable() {
        let predicates = SearchPredicates()

        XCTAssertTrue(predicates.categories.contains(.buttons))
        XCTAssertTrue(predicates.categories.contains(.checkboxes))
        XCTAssertTrue(predicates.categories.contains(.controls))
        XCTAssertTrue(predicates.categories.contains(.graphics))
        XCTAssertTrue(predicates.categories.contains(.links))
        XCTAssertTrue(predicates.categories.contains(.radioGroups))
        XCTAssertTrue(predicates.categories.contains(.textFields))
    }

    func testSearchCategoryCount() {
        let predicates = SearchPredicates()

        XCTAssertEqual(predicates.categories.count, 7)
    }

    // MARK: - Role Mapping

    func testButtonRoles() {
        let predicates = SearchPredicates()

        let buttonRoles = predicates.roles(for: .buttons)

        XCTAssertTrue(buttonRoles.contains("AXButton"))
        XCTAssertTrue(buttonRoles.contains("AXPopUpButton"))
    }

    func testLinkRoles() {
        let predicates = SearchPredicates()

        let linkRoles = predicates.roles(for: .links)

        XCTAssertTrue(linkRoles.contains("AXLink"))
    }

    func testTextFieldRoles() {
        let predicates = SearchPredicates()

        let textFieldRoles = predicates.roles(for: .textFields)

        XCTAssertTrue(textFieldRoles.contains("AXTextField"))
        XCTAssertTrue(textFieldRoles.contains("AXTextArea"))
    }

    // MARK: - Deduplication

    func testDeduplicatesResults() {
        let deduplicator = SearchResultDeduplicator<MockSearchElement>()

        let elements: [MockSearchElement] = [
            MockSearchElement(identifier: "1", role: "AXButton"),
            MockSearchElement(identifier: "1", role: "AXButton"),  // Duplicate
            MockSearchElement(identifier: "2", role: "AXLink")
        ]

        let deduplicated = deduplicator.deduplicate(elements)

        XCTAssertEqual(deduplicated.count, 2)
    }

    func testDeduplicationPreservesOrder() {
        let deduplicator = SearchResultDeduplicator<MockSearchElement>()

        let elements: [MockSearchElement] = [
            MockSearchElement(identifier: "A", role: "AXButton"),
            MockSearchElement(identifier: "B", role: "AXLink"),
            MockSearchElement(identifier: "A", role: "AXButton"),  // Duplicate
            MockSearchElement(identifier: "C", role: "AXCheckBox")
        ]

        let deduplicated = deduplicator.deduplicate(elements)

        XCTAssertEqual(deduplicated.count, 3)
        XCTAssertEqual(deduplicated[0].identifier, "A")
        XCTAssertEqual(deduplicated[1].identifier, "B")
        XCTAssertEqual(deduplicated[2].identifier, "C")
    }

    // MARK: - Combined Search

    func testCombineMultipleCategories() {
        let predicates = SearchPredicates()

        let combinedRoles = predicates.roles(for: [.buttons, .links])

        XCTAssertTrue(combinedRoles.contains("AXButton"))
        XCTAssertTrue(combinedRoles.contains("AXLink"))
    }

    func testAllCategoriesCombined() {
        let predicates = SearchPredicates()

        let allRoles = predicates.allRoles

        // Should have roles from all categories
        XCTAssertGreaterThan(allRoles.count, 7)
    }
}
