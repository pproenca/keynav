// Sources/KeyNav/Core/ScrollKeyPrefs.swift
import Foundation

/// User preferences for scroll key bindings
struct ScrollKeyPrefs: Codable, Equatable {
    /// Comma-separated key string
    let keyString: String

    /// Valid key counts
    static let validKeyCounts: Set<Int> = [4, 6, 8]

    init(keyString: String = "h,j,k,l,d,u,g,G") {
        self.keyString = keyString
    }

    /// Parsed array of keys
    var keys: [String] {
        return
            keyString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// Validate a scroll key configuration string
    /// - Parameter keyString: Comma-separated key string
    /// - Returns: True if valid (4, 6, or 8 unique keys)
    static func isValid(_ keyString: String) -> Bool {
        let keys =
            keyString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        // Must be 4, 6, or 8 keys
        guard validKeyCounts.contains(keys.count) else {
            return false
        }

        // All keys must be unique
        let uniqueKeys = Set(keys)
        return uniqueKeys.count == keys.count
    }
}
