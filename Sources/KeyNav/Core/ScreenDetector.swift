// Sources/KeyNav/Core/ScreenDetector.swift
import Foundation

/// Detects which screen a window is on, handling fullscreen and multi-display scenarios
struct ScreenDetector {

    /// Find the screen that contains most of the window
    /// - Parameters:
    ///   - windowFrame: The window's frame in screen coordinates
    ///   - screens: Array of screen frames to check
    /// - Returns: The screen frame with the largest intersection, or nil if no screens
    func findScreen(for windowFrame: CGRect, screens: [CGRect]) -> CGRect? {
        guard !screens.isEmpty else { return nil }

        var bestScreen: CGRect?
        var bestArea: CGFloat = 0

        for screen in screens {
            let area = intersectionArea(windowFrame, screen)
            if area > bestArea {
                bestArea = area
                bestScreen = screen
            }
        }

        return bestScreen
    }

    /// Calculate the intersection area between two rectangles
    /// - Returns: The area of intersection, or 0 if no intersection
    func intersectionArea(_ rect1: CGRect, _ rect2: CGRect) -> CGFloat {
        let intersection = rect1.intersection(rect2)
        if intersection.isNull {
            return 0
        }
        return intersection.width * intersection.height
    }

    /// Check if a window is fullscreen on a given screen
    /// - Parameters:
    ///   - windowFrame: The window's frame
    ///   - screenFrame: The screen's frame
    ///   - tolerance: Percentage tolerance (0.0-1.0) for near-fullscreen windows
    /// - Returns: True if the window covers most of the screen
    func isFullscreen(_ windowFrame: CGRect, on screenFrame: CGRect, tolerance: CGFloat = 0.0) -> Bool {
        let screenArea = screenFrame.width * screenFrame.height
        let windowArea = windowFrame.width * windowFrame.height

        if tolerance == 0 {
            // Exact match required
            return windowFrame.equalTo(screenFrame)
        }

        // Check if window covers at least (1 - tolerance) of the screen
        let minArea = screenArea * (1 - tolerance)
        return windowArea >= minArea && windowFrame.intersects(screenFrame)
    }
}
