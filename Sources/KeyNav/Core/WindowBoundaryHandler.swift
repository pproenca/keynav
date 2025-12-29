// Sources/KeyNav/Core/WindowBoundaryHandler.swift
import Foundation

/// Handles windows that extend beyond screen boundaries
struct WindowBoundaryHandler {

    /// Clips a window frame to the visible portion within a screen
    /// - Parameters:
    ///   - window: The window's frame
    ///   - screen: The screen's frame
    /// - Returns: The portion of the window visible on screen, or empty rect if none
    func clipToScreen(_ window: CGRect, screen: CGRect) -> CGRect {
        let intersection = window.intersection(screen)
        return intersection.isNull ? .zero : intersection
    }

    /// Calculate what percentage of a window is visible on screen
    /// - Parameters:
    ///   - window: The window's frame
    ///   - screen: The screen's frame
    /// - Returns: Value from 0.0 (not visible) to 1.0 (fully visible)
    func visiblePercentage(of window: CGRect, on screen: CGRect) -> CGFloat {
        let windowArea = window.width * window.height
        guard windowArea > 0 else { return 0 }

        let clipped = clipToScreen(window, screen: screen)
        let clippedArea = clipped.width * clipped.height

        return clippedArea / windowArea
    }
}
