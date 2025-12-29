// Sources/KeyNav/Core/ScrollValueLimits.swift
import Foundation

/// Limits for scroll values to ensure compatibility with various applications
///
/// VS Code Compatibility Note:
/// VS Code has a bug where using Int32.max for upward scrolling causes it to
/// scroll to the bottom instead of the top. Using Int16.max (32767) works correctly.
struct ScrollValueLimits: Codable, Equatable {

    /// Maximum scroll value for upward scrolling (positive delta)
    let maxScrollUp: Int

    /// Maximum scroll value for downward scrolling (positive magnitude)
    let maxScrollDown: Int

    /// Default limits use Int16.max for VS Code compatibility
    init(maxScrollUp: Int = Int(Int16.max), maxScrollDown: Int = Int(Int16.max)) {
        self.maxScrollUp = maxScrollUp
        self.maxScrollDown = maxScrollDown
    }

    /// Clamps an upward scroll value to the maximum allowed
    func clampScrollUp(_ value: Int) -> Int {
        if value >= 0 {
            return min(value, maxScrollUp)
        } else {
            return max(value, -maxScrollUp)
        }
    }

    /// Clamps a downward scroll value to the maximum allowed
    func clampScrollDown(_ value: Int) -> Int {
        if value >= 0 {
            return min(value, maxScrollDown)
        } else {
            return max(value, -maxScrollDown)
        }
    }
}
