// Sources/KeyNav/Core/ScrollAreaDetection.swift
import Foundation

/// Protocol for scroll area elements
protocol ScrollAreaProtocol {
    var frame: CGRect { get }
    var role: String { get }
    var surfaceArea: CGFloat { get }
}

/// Configuration for scroll area detection
struct ScrollAreaConfig {
    /// Roles that should be skipped during traversal
    private static let skipRoles: Set<String> = ["AXWebArea"]

    /// Roles that use visibleRows attribute instead of all children
    private static let visibleRowsRoles: Set<String> = ["AXTable", "AXOutline"]

    /// Check if a role should be skipped
    func shouldSkip(role: String) -> Bool {
        return Self.skipRoles.contains(role)
    }

    /// Check if a role should use visibleRows
    func useVisibleRows(for role: String) -> Bool {
        return Self.visibleRowsRoles.contains(role)
    }
}

/// Finds scroll areas using depth-first traversal
final class ScrollAreaFinder {
    private let config = ScrollAreaConfig()

    /// Find all scroll areas from a collection, sorted by surface area (largest first)
    /// Skips web areas and other non-scrollable containers
    func findScrollAreas<T: ScrollAreaProtocol>(from areas: [T]) -> [T] {
        // Filter out skipped roles (e.g., AXWebArea)
        let filteredAreas = areas.filter { !config.shouldSkip(role: $0.role) }

        // Sort by surface area, largest first
        let sortedAreas = filteredAreas.sorted { $0.surfaceArea > $1.surfaceArea }

        return sortedAreas
    }
}
