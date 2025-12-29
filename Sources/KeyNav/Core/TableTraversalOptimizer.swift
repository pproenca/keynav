// Sources/KeyNav/Core/TableTraversalOptimizer.swift
import Foundation

/// Optimizes traversal of tables and outlines using visible rows
/// instead of querying all children for better performance with large data sets
struct TableTraversalOptimizer {

    /// Roles that represent table-like structures
    private static let tableRoles: Set<String> = ["AXTable", "AXOutline"]

    // MARK: - Accessibility Attribute Names

    /// Attribute for visible rows in a table
    let visibleRowsAttribute = "AXVisibleRows"

    /// Attribute for visible children
    let visibleChildrenAttribute = "AXVisibleChildren"

    /// Attribute for expanded state in outline
    let expandedAttribute = "AXExpanded"

    /// Attribute for disclosed rows in outline
    let disclosedRowsAttribute = "AXDisclosedRows"

    // MARK: - Role Detection

    /// Check if a role represents a table-like structure
    func isTableRole(_ role: String) -> Bool {
        return Self.tableRoles.contains(role)
    }

    /// Check if visible rows optimization should be used
    func shouldUseVisibleRows(for role: String) -> Bool {
        return isTableRole(role)
    }

    // MARK: - Row Filtering

    /// Filter a collection to only visible items
    /// - Parameters:
    ///   - items: All items to filter
    ///   - isVisible: Predicate to check visibility
    /// - Returns: Only the visible items, preserving order
    func filterVisible<T>(_ items: [T], isVisible: (T) -> Bool) -> [T] {
        return items.filter(isVisible)
    }
}
