// Sources/KeyNav/Accessibility/AXHelpers.swift
import ApplicationServices

/// Helper functions for safely working with Accessibility API types.
///
/// CoreFoundation types like AXUIElement are opaque and cannot be conditionally cast
/// at runtime using `as?`. The AX API guarantees that when a call returns `.success`,
/// the returned value is of the expected type. These helpers provide a clean pattern
/// for working with these types safely.
enum AXHelpers {
    /// Retrieves an AXUIElement attribute value from an element.
    /// Returns nil if the call fails or the value is nil.
    static func getElement(
        from element: AXUIElement,
        attribute: CFString
    ) -> AXUIElement? {
        var ref: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &ref)
        guard result == .success, ref != nil else { return nil }
        // AX API guarantees correct type on success
        return (ref as! AXUIElement)  // swiftlint:disable:this force_cast
    }

    /// Retrieves an AXValue (CGPoint/CGSize/etc.) attribute value from an element.
    /// Returns nil if the call fails or the value is nil.
    static func getValue(
        from element: AXUIElement,
        attribute: CFString
    ) -> AXValue? {
        var ref: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &ref)
        guard result == .success, ref != nil else { return nil }
        // AX API guarantees correct type on success
        return (ref as! AXValue)  // swiftlint:disable:this force_cast
    }

    /// Retrieves a CGPoint from an AXValue position attribute.
    static func getPosition(from element: AXUIElement) -> CGPoint? {
        guard let value = getValue(from: element, attribute: kAXPositionAttribute as CFString) else {
            return nil
        }
        var point = CGPoint.zero
        guard AXValueGetValue(value, .cgPoint, &point) else { return nil }
        return point
    }

    /// Retrieves a CGSize from an AXValue size attribute.
    static func getSize(from element: AXUIElement) -> CGSize? {
        guard let value = getValue(from: element, attribute: kAXSizeAttribute as CFString) else {
            return nil
        }
        var size = CGSize.zero
        guard AXValueGetValue(value, .cgSize, &size) else { return nil }
        return size
    }

    /// Retrieves the frame (position + size) of an element.
    static func getFrame(from element: AXUIElement) -> CGRect? {
        guard let position = getPosition(from: element),
              let size = getSize(from: element) else {
            return nil
        }
        return CGRect(origin: position, size: size)
    }
}
