// Sources/KeyNav/Core/SearchPredicates.swift
import Foundation

/// Protocol for elements that can be searched and deduplicated
protocol SearchableElement {
    var identifier: String { get }
    var role: String { get }
}

/// Categories of elements to search for
enum SearchCategory: CaseIterable {
    case buttons
    case checkboxes
    case controls
    case graphics
    case links
    case radioGroups
    case textFields
}

/// Search predicates for querying accessibility elements
struct SearchPredicates {
    /// All available search categories
    let categories: [SearchCategory] = SearchCategory.allCases

    /// Role mappings for each category
    private let categoryRoles: [SearchCategory: Set<String>] = [
        .buttons: ["AXButton", "AXPopUpButton", "AXMenuButton"],
        .checkboxes: ["AXCheckBox"],
        .controls: [
            "AXButton", "AXCheckBox", "AXRadioButton", "AXTextField",
            "AXTextArea", "AXPopUpButton", "AXSlider", "AXComboBox",
        ],
        .graphics: ["AXImage", "AXIcon"],
        .links: ["AXLink"],
        .radioGroups: ["AXRadioGroup", "AXRadioButton"],
        .textFields: ["AXTextField", "AXTextArea", "AXComboBox", "AXSearchField"],
    ]

    /// Get roles for a single category
    func roles(for category: SearchCategory) -> Set<String> {
        return categoryRoles[category] ?? []
    }

    /// Get combined roles for multiple categories
    func roles(for categories: [SearchCategory]) -> Set<String> {
        var combined = Set<String>()
        for category in categories {
            combined.formUnion(roles(for: category))
        }
        return combined
    }

    /// Get all roles from all categories
    var allRoles: Set<String> {
        return roles(for: SearchCategory.allCases)
    }
}

/// Deduplicates search results based on element identifier
struct SearchResultDeduplicator<T: SearchableElement> {
    /// Deduplicate elements, preserving first occurrence order
    func deduplicate(_ elements: [T]) -> [T] {
        var seen = Set<String>()
        var result = [T]()

        for element in elements where !seen.contains(element.identifier) {
            seen.insert(element.identifier)
            result.append(element)
        }

        return result
    }
}
