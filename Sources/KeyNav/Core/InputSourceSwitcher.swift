// Sources/KeyNav/Core/InputSourceSwitcher.swift
import Foundation

/// Manages programmatic input source switching
struct InputSourceSwitcher {
    /// Domain for symbolic hotkeys preferences
    let shortcutDomain = "com.apple.symbolichotkeys"

    /// Keyboard shortcut ID for "Select next input source"
    let nextInputSourceKeyID = 60

    /// Keyboard shortcut ID for "Select previous input source"
    let previousInputSourceKeyID = 61

    /// Originally active input source (to restore later)
    private(set) var originalSource: String?

    /// Parse modifier flags from shortcut configuration
    /// - Parameter flags: The modifier flags integer
    /// - Returns: KeyModifiers set
    func parseModifiers(_ flags: Int) -> KeyModifiers {
        var modifiers = KeyModifiers()

        if (flags & 131072) != 0 { modifiers.insert(.shift) }
        if (flags & 262144) != 0 { modifiers.insert(.control) }
        if (flags & 524288) != 0 { modifiers.insert(.option) }
        if (flags & 1048576) != 0 { modifiers.insert(.command) }

        return modifiers
    }

    /// Save the current input source for later restoration
    mutating func saveOriginalSource(_ identifier: String) {
        originalSource = identifier
    }

    /// Clear the saved original source
    mutating func clearOriginalSource() {
        originalSource = nil
    }
}
