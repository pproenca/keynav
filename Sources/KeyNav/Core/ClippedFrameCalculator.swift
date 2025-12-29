// Sources/KeyNav/Core/ClippedFrameCalculator.swift
import Foundation

/// Calculates visible portions of elements within scroll area viewports
struct ClippedFrameCalculator {

    /// Calculate the visible frame of an element within a viewport
    /// - Parameters:
    ///   - element: The element's frame
    ///   - viewport: The viewport bounds (scroll area visible region)
    /// - Returns: The visible portion of the element, or empty rect if not visible
    func visibleFrame(of element: CGRect, in viewport: CGRect) -> CGRect {
        let intersection = element.intersection(viewport)
        return intersection.isNull ? .zero : intersection
    }

    /// Check if an element is at least partially visible in a viewport
    /// - Parameters:
    ///   - element: The element's frame
    ///   - viewport: The viewport bounds
    /// - Returns: True if any part of the element is visible
    func isVisible(_ element: CGRect, in viewport: CGRect) -> Bool {
        return element.intersects(viewport)
    }

    /// Check if an element has a meaningful visible area
    /// - Parameters:
    ///   - element: The element's frame
    ///   - viewport: The viewport bounds
    ///   - minArea: Minimum visible area in square points (default: 25)
    /// - Returns: True if the visible area exceeds the minimum threshold
    func isMeaningfullyVisible(_ element: CGRect, in viewport: CGRect, minArea: CGFloat = 25) -> Bool {
        let visible = visibleFrame(of: element, in: viewport)
        let area = visible.width * visible.height
        return area >= minArea
    }
}
