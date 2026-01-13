// Sources/KeyNav/Core/Strings.swift
import Foundation

/// Type-safe localized string access for KeyNav.
///
/// All user-facing strings should be accessed through this enum to enable:
/// - Type-safe string access (no typos in keys)
/// - Centralized string management
/// - Easy localization preparation
/// - Compile-time verification of string existence
///
/// Usage:
///     label.stringValue = Strings.Preferences.hintModeLabel
///
/// When adding new strings:
/// 1. Add the string constant here
/// 2. Use NSLocalizedString with the same key for the value
/// 3. When localization is enabled, add keys to Localizable.strings
enum Strings {
    // MARK: - App

    enum App {
        static let name = NSLocalizedString("app.name", value: "KeyNav", comment: "Application name")
        static let setupTitle = NSLocalizedString(
            "app.setup.title", value: "KeyNav Setup", comment: "Setup window title"
        )
        static let accessibilityRequired = NSLocalizedString(
            "app.accessibility.required",
            value: "KeyNav needs accessibility access to detect UI elements.",
            comment: "Accessibility permission description"
        )
        static let openSystemPreferences = NSLocalizedString(
            "app.accessibility.open_preferences",
            value: "Open System Preferences",
            comment: "Button to open System Preferences"
        )
    }

    // MARK: - Hint Mode

    enum HintMode {
        static let noHintsAvailable = NSLocalizedString(
            "hint.no_hints",
            value: "No hints available",
            comment: "VoiceOver label when no hints are displayed"
        )
        static let hintsDisplayed = NSLocalizedString(
            "hint.count",
            value: "%d keyboard hints displayed",
            comment: "VoiceOver label with hint count"
        )
        static func hintsDisplayedFormatted(_ count: Int) -> String {
            String(format: hintsDisplayed, count)
        }
        static let pressToActivate = NSLocalizedString(
            "hint.press_to_activate",
            value: "Press %@ to activate",
            comment: "VoiceOver label for individual hint"
        )
        static func pressToActivateFormatted(_ key: String) -> String {
            String(format: pressToActivate, key)
        }
        static let roleDescription = NSLocalizedString(
            "hint.role_description",
            value: "Keyboard navigation hints",
            comment: "VoiceOver role description for hint view"
        )
        static let hintKeyRole = NSLocalizedString(
            "hint.key_role",
            value: "Hint key",
            comment: "VoiceOver role for individual hint"
        )
    }

    // MARK: - Input Display

    enum InputDisplay {
        static let noInput = NSLocalizedString(
            "input.no_input",
            value: "No input",
            comment: "Accessibility label when no characters typed"
        )
        static let typed = NSLocalizedString(
            "input.typed",
            value: "Typed: %@",
            comment: "Accessibility label showing typed characters"
        )
        static func typedFormatted(_ text: String) -> String {
            String(format: typed, text)
        }
        static let roleDescription = NSLocalizedString(
            "input.role_description",
            value: "Typed hint characters",
            comment: "VoiceOver role description for input display"
        )
    }

    // MARK: - Search Mode

    enum SearchMode {
        static let placeholder = NSLocalizedString(
            "search.placeholder",
            value: "Type to search or press hint key...",
            comment: "Search bar placeholder text"
        )
        static let groupLabel = NSLocalizedString(
            "search.group_label",
            value: "Search UI elements",
            comment: "Accessibility label for search group"
        )
        static let fieldLabel = NSLocalizedString(
            "search.field_label",
            value: "Search field",
            comment: "Accessibility label for search field"
        )
        static let fieldRoleDescription = NSLocalizedString(
            "search.field_role",
            value: "Search for UI elements to navigate",
            comment: "VoiceOver role description for search field"
        )
    }

    // MARK: - Preferences

    enum Preferences {
        static let title = NSLocalizedString(
            "prefs.title",
            value: "KeyNav Preferences",
            comment: "Preferences window title"
        )
        static let shortcutsTab = NSLocalizedString(
            "prefs.tab.shortcuts",
            value: "Shortcuts",
            comment: "Shortcuts tab label"
        )
        static let hintsTab = NSLocalizedString(
            "prefs.tab.hints",
            value: "Hints",
            comment: "Hints tab label"
        )
        static let diagnosticTab = NSLocalizedString(
            "prefs.tab.diagnostic",
            value: "Diagnostic",
            comment: "Diagnostic tab label"
        )

        // Shortcuts
        static let keyboardShortcuts = NSLocalizedString(
            "prefs.shortcuts.title",
            value: "Keyboard Shortcuts",
            comment: "Shortcuts section title"
        )
        static let hintModeLabel = NSLocalizedString(
            "prefs.shortcuts.hint_mode",
            value: "Hint Mode:",
            comment: "Hint mode shortcut label"
        )
        static let scrollModeLabel = NSLocalizedString(
            "prefs.shortcuts.scroll_mode",
            value: "Scroll Mode:",
            comment: "Scroll mode shortcut label"
        )
        static let searchModeLabel = NSLocalizedString(
            "prefs.shortcuts.search_mode",
            value: "Search Mode:",
            comment: "Search mode shortcut label"
        )
        static let shortcutInstructions = NSLocalizedString(
            "prefs.shortcuts.instructions",
            value: "Click a shortcut field and press your desired key combination to change it.",
            comment: "Instructions for changing shortcuts"
        )
        static let reregisterShortcuts = NSLocalizedString(
            "prefs.shortcuts.reregister",
            value: "Re-register All Shortcuts",
            comment: "Button to re-register shortcuts"
        )
        static let resetDefaults = NSLocalizedString(
            "prefs.shortcuts.reset",
            value: "Reset to Defaults",
            comment: "Button to reset shortcuts to defaults"
        )

        // Hints
        static let hintSettings = NSLocalizedString(
            "prefs.hints.title",
            value: "Hint Settings",
            comment: "Hints section title"
        )
        static let hintCharactersLabel = NSLocalizedString(
            "prefs.hints.characters",
            value: "Hint Characters:",
            comment: "Hint characters setting label"
        )
        static let hintCharactersHelp = NSLocalizedString(
            "prefs.hints.characters_help",
            value: "Characters used for hint labels (e.g., 'sadfjklewcmpgh')",
            comment: "Help text for hint characters"
        )
        static let hintTextSizeLabel = NSLocalizedString(
            "prefs.hints.text_size",
            value: "Hint Text Size:",
            comment: "Hint text size setting label"
        )

        // Diagnostic
        static let systemStatus = NSLocalizedString(
            "prefs.diagnostic.title",
            value: "System Status",
            comment: "Diagnostic section title"
        )
        static let accessibilityPermission = NSLocalizedString(
            "prefs.diagnostic.accessibility",
            value: "Accessibility Permission:",
            comment: "Accessibility permission status label"
        )
        static let keyboardCapture = NSLocalizedString(
            "prefs.diagnostic.keyboard_capture",
            value: "Keyboard Capture:",
            comment: "Keyboard capture status label"
        )
        static let statusOperational = NSLocalizedString(
            "prefs.status.operational",
            value: "Operational",
            comment: "Status: working correctly"
        )
        static let statusUnknown = NSLocalizedString(
            "prefs.status.unknown",
            value: "Unknown",
            comment: "Status: unknown state"
        )
        static let statusDisabled = NSLocalizedString(
            "prefs.status.disabled",
            value: "Disabled",
            comment: "Status: feature disabled"
        )
        static let statusFailed = NSLocalizedString(
            "prefs.status.failed",
            value: "Failed: %@",
            comment: "Status: failed with reason"
        )
        static func statusFailedFormatted(_ reason: String) -> String {
            String(format: statusFailed, reason)
        }
        static let requestButton = NSLocalizedString(
            "prefs.diagnostic.request",
            value: "Request",
            comment: "Button to request permission"
        )
        static let refreshStatus = NSLocalizedString(
            "prefs.diagnostic.refresh",
            value: "Refresh Status",
            comment: "Button to refresh diagnostic status"
        )
        static let copyDiagnostic = NSLocalizedString(
            "prefs.diagnostic.copy",
            value: "Copy Diagnostic Info",
            comment: "Button to copy diagnostic info"
        )
        static let retryAll = NSLocalizedString(
            "prefs.diagnostic.retry",
            value: "Retry All",
            comment: "Button to retry all registrations"
        )
    }

    // MARK: - Menu

    enum Menu {
        static let preferences = NSLocalizedString(
            "menu.preferences",
            value: "Preferences...",
            comment: "Preferences menu item"
        )
        static let diagnostic = NSLocalizedString(
            "menu.diagnostic",
            value: "Diagnostic",
            comment: "Diagnostic menu item"
        )
        static let about = NSLocalizedString(
            "menu.about",
            value: "About KeyNav",
            comment: "About menu item"
        )
        static let quit = NSLocalizedString(
            "menu.quit",
            value: "Quit",
            comment: "Quit menu item"
        )
    }

    // MARK: - Alerts

    enum Alerts {
        static let success = NSLocalizedString(
            "alert.success",
            value: "Success",
            comment: "Success alert title"
        )
        static let allShortcutsRegistered = NSLocalizedString(
            "alert.shortcuts_registered",
            value: "All shortcuts registered successfully.",
            comment: "Message when all shortcuts registered"
        )
        static let someShortcutsFailed = NSLocalizedString(
            "alert.some_shortcuts_failed",
            value: "Some Shortcuts Failed",
            comment: "Title when some shortcuts failed"
        )
        static let shortcutsConflict = NSLocalizedString(
            "alert.shortcuts_conflict",
            value: "Not all shortcuts could be registered. Check for conflicts with other applications.",
            comment: "Message about shortcut conflicts"
        )
        static let resetComplete = NSLocalizedString(
            "alert.reset_complete",
            value: "Reset Complete",
            comment: "Title when reset is complete"
        )
        static let shortcutsResetToDefaults = NSLocalizedString(
            "alert.shortcuts_reset",
            value: "Shortcuts have been reset to defaults.",
            comment: "Message when shortcuts reset"
        )
        static let copied = NSLocalizedString(
            "alert.copied",
            value: "Copied",
            comment: "Title when content copied"
        )
        static let diagnosticCopied = NSLocalizedString(
            "alert.diagnostic_copied",
            value: "Diagnostic information copied to clipboard.",
            comment: "Message when diagnostic copied"
        )
        static let ok = NSLocalizedString(
            "alert.ok",
            value: "OK",
            comment: "OK button"
        )
    }
}
