// Sources/KeyNav/Core/ScrollTimingConfig.swift
import Foundation

/// Types of scroll actions with different timing behaviors
enum ScrollType: Equatable {
    /// Directional scrolling (HJKL) - smooth, fast repeat
    case directional
    /// Half-page scrolling (D/U) - chunky, slow repeat
    case halfPage
    /// Jump scrolling (gg/G) - no repeat
    case jump
}

/// Configuration for scroll timing intervals
/// Controls how quickly scroll events repeat when a key is held
struct ScrollTimingConfig: Codable, Equatable {

    /// Interval for smooth scrolling (directional keys HJKL)
    /// Default: 1/50s = 0.02s for responsive scrolling
    let smoothScrollInterval: TimeInterval

    /// Interval for chunky scrolling (half-page keys D/U)
    /// Default: 0.25s for deliberate page jumps
    let chunkyScrollInterval: TimeInterval

    init(smoothScrollInterval: TimeInterval = 0.02, chunkyScrollInterval: TimeInterval = 0.25) {
        self.smoothScrollInterval = smoothScrollInterval
        self.chunkyScrollInterval = chunkyScrollInterval
    }

    /// Returns the appropriate repeat interval for a scroll type
    /// - Parameter scrollType: The type of scroll action
    /// - Returns: The interval in seconds, or nil if the action should not repeat
    func interval(for scrollType: ScrollType) -> TimeInterval? {
        switch scrollType {
        case .directional:
            return smoothScrollInterval
        case .halfPage:
            return chunkyScrollInterval
        case .jump:
            return nil  // Jump actions (gg/G) should not repeat
        }
    }
}
