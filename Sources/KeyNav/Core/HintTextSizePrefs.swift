// Sources/KeyNav/Core/HintTextSizePrefs.swift
import Foundation

/// User preferences for hint text size
struct HintTextSizePrefs: Codable, Equatable {
    /// Font size for hint labels
    let size: CGFloat

    /// Minimum allowed size (exclusive of 0)
    static let minSize: CGFloat = 1.0

    /// Maximum allowed size
    static let maxSize: CGFloat = 100.0

    init(size: CGFloat = 11.0) {
        self.size = size
    }

    /// Validate a hint text size
    /// - Parameter size: The size to validate
    /// - Returns: True if valid (between 0 exclusive and 100 inclusive)
    static func isValid(_ size: CGFloat) -> Bool {
        return size > 0 && size <= maxSize
    }

    /// Clamp a size to the valid range
    /// - Parameter size: The size to clamp
    /// - Returns: Size clamped to valid range
    static func clamp(_ size: CGFloat) -> CGFloat {
        return max(minSize, min(maxSize, size))
    }
}
