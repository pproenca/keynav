// Sources/KeyNav/Core/ClickPositionCalculator.swift
import Foundation

/// Calculates the optimal click position for different element types
/// AXLink and AXStaticText elements are clicked at bottom-left (offset by 5px)
/// because links often have clickable text there. Other elements use center.
enum ClickPositionCalculator {

    /// The offset from edges for link-type elements
    private static let linkOffset: CGFloat = 5.0

    /// Roles that should be clicked at bottom-left instead of center
    private static let bottomLeftClickRoles: Set<String> = [
        "AXLink",
        "AXStaticText"
    ]

    /// Calculates the optimal click position for an element
    /// - Parameter element: The element to calculate position for
    /// - Returns: The CGPoint where the click should occur
    static func clickPosition(for element: ActionableElement) -> CGPoint {
        if bottomLeftClickRoles.contains(element.role) {
            return bottomLeftPosition(for: element.frame)
        } else {
            return centerPosition(for: element.frame)
        }
    }

    /// Returns the center point of a frame
    private static func centerPosition(for frame: CGRect) -> CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY)
    }

    /// Returns the bottom-left position with offset, clamped to frame bounds
    private static func bottomLeftPosition(for frame: CGRect) -> CGPoint {
        // Calculate offset position
        let x = frame.origin.x + linkOffset
        let y = frame.origin.y + frame.height - linkOffset

        // Clamp to stay within frame bounds
        let clampedX = min(max(x, frame.origin.x), frame.origin.x + frame.width)
        let clampedY = min(max(y, frame.origin.y), frame.origin.y + frame.height)

        return CGPoint(x: clampedX, y: clampedY)
    }
}
