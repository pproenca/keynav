// Sources/KeyNav/Core/ScrollSensitivityConfig.swift
import Foundation

/// Configuration for scroll sensitivity
/// Maps a 0-100 sensitivity value to actual scroll amounts
struct ScrollSensitivityConfig: Codable, Equatable {

    /// Sensitivity value (0-100)
    /// 0 = slowest scrolling, 100 = fastest scrolling
    let sensitivity: Int

    // Scroll amount ranges
    private static let minSmallScroll: CGFloat = 10
    private static let maxSmallScroll: CGFloat = 200
    private static let minPageScroll: CGFloat = 60
    private static let maxPageScroll: CGFloat = 600

    /// Default sensitivity (matches Vimac's default of 20)
    init(sensitivity: Int = 20) {
        // Clamp to 0-100 range
        self.sensitivity = max(0, min(100, sensitivity))
    }

    /// Scroll amount for directional scrolling (HJKL)
    var smallScrollAmount: CGFloat {
        let percentage = CGFloat(sensitivity) / 100.0
        let range = Self.maxSmallScroll - Self.minSmallScroll
        return Self.minSmallScroll + range * percentage
    }

    /// Scroll amount for half-page scrolling (D/U)
    var pageScrollAmount: CGFloat {
        let percentage = CGFloat(sensitivity) / 100.0
        let range = Self.maxPageScroll - Self.minPageScroll
        return Self.minPageScroll + range * percentage
    }
}
