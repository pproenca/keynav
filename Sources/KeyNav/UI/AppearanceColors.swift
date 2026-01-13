// Sources/KeyNav/UI/AppearanceColors.swift
import AppKit

/// Helper for checking system accessibility preferences.
enum SystemAccessibility {
    /// Whether the user has enabled "Reduce Motion" in System Settings.
    static var reduceMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    /// Whether the user has enabled "Reduce Transparency" in System Settings.
    static var reduceTransparency: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
    }

    /// Whether the user has enabled "Increase Contrast" in System Settings.
    static var increaseContrast: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
    }
}

/// Centralized appearance-aware colors for KeyNav UI elements.
///
/// These colors automatically adapt when the system appearance changes between
/// light and dark mode. The design maintains KeyNav's signature yellow/gold
/// hint style while ensuring readability in both modes.
///
/// Colors also respect system accessibility preferences:
/// - Increase Contrast: Uses higher contrast color combinations
/// - Reduce Transparency: Uses solid colors without alpha
enum AppearanceColors {
    // MARK: - Hint Colors

    /// Background color for hint labels.
    /// Light mode: Pale yellow (signature KeyNav color)
    /// Dark mode: Muted gold that's visible but not glaring
    /// High contrast mode: Brighter, more saturated colors
    static let hintBackground = NSColor(name: nil) { appearance in
        let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        let highContrast = SystemAccessibility.increaseContrast

        if isDark {
            if highContrast {
                // Brighter gold for high contrast dark mode
                return NSColor(calibratedRed: 0.55, green: 0.50, blue: 0.20, alpha: 1.0)
            }
            // Muted gold for dark mode - less saturated to reduce eye strain
            return NSColor(calibratedRed: 0.45, green: 0.40, blue: 0.15, alpha: 0.95)
        } else {
            if highContrast {
                // More saturated yellow for high contrast light mode
                return NSColor(calibratedRed: 1.0, green: 0.85, blue: 0.30, alpha: 1.0)
            }
            // Original pale yellow for light mode
            return NSColor(calibratedRed: 1.0, green: 0.88, blue: 0.44, alpha: 1.0)
        }
    }

    /// Text color for hint labels (unmatched/untyped characters).
    /// Ensures WCAG 4.5:1 contrast ratio against hint background.
    static let hintText = NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return .white
        default:
            return .black
        }
    }

    /// Text color for matched (typed) hint characters.
    /// Golden brown that indicates progress without losing visibility.
    static let hintMatchedText = NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            // Lighter golden for dark mode
            return NSColor(calibratedRed: 0.85, green: 0.75, blue: 0.45, alpha: 1.0)
        default:
            // Original golden brown for light mode
            return NSColor(calibratedRed: 0.83, green: 0.67, blue: 0.23, alpha: 1.0)
        }
    }

    /// Border color for hint labels.
    static let hintBorder = NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return NSColor(calibratedWhite: 0.4, alpha: 1.0)
        default:
            return .darkGray
        }
    }

    // MARK: - Input Display Colors

    /// Background color for the input display (shows typed hint characters).
    /// Respects Reduce Transparency preference by using solid colors.
    static let inputDisplayBackground = NSColor(name: nil) { appearance in
        let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua

        // Use solid color when reduce transparency is enabled
        if SystemAccessibility.reduceTransparency {
            return isDark ? NSColor(calibratedWhite: 0.1, alpha: 1.0) : NSColor(calibratedWhite: 0.15, alpha: 1.0)
        }

        return isDark
            ? NSColor.black.withAlphaComponent(0.85)
            : NSColor.black.withAlphaComponent(0.8)
    }

    /// Text color for the input display.
    static let inputDisplayText: NSColor = .white

    // MARK: - Search Bar Colors

    /// Background color for search bar container.
    static let searchBarBackground: NSColor = .windowBackgroundColor

    /// Placeholder text color for search field.
    static let searchBarPlaceholder: NSColor = .placeholderTextColor

    // MARK: - Scroll Indicator Colors

    /// Border color for scroll mode indicator.
    static let scrollIndicatorBorder: NSColor = .systemRed
}
