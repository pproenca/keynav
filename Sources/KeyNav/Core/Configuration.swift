// Sources/KeyNav/Core/Configuration.swift
import Foundation

/// Centralized configuration management for KeyNav.
///
/// All user preferences are accessed and modified through this class,
/// which provides type-safe access to UserDefaults values with sensible defaults.
/// This enables future migration to different storage backends if needed.
final class Configuration {
    // MARK: - Singleton

    static let shared = Configuration()

    // MARK: - Storage Keys

    private enum Key: String {
        case hintCharacters
        case hintTextSize
        case hotkeyConfigurations
        case launchAtLogin
        case showMenuBarIcon
    }

    // MARK: - Defaults

    private enum Defaults {
        static let hintCharacters = "sadfjklewcmpgh"
        static let hintTextSize: CGFloat = 11.0
        static let launchAtLogin = false
        static let showMenuBarIcon = true
    }

    // MARK: - Private

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Hint Preferences

    /// The characters used for hint labels.
    /// Default: "sadfjklewcmpgh" (Vimac's default home-row friendly characters)
    var hintCharacters: String {
        get {
            defaults.string(forKey: Key.hintCharacters.rawValue) ?? Defaults.hintCharacters
        }
        set {
            defaults.set(newValue, forKey: Key.hintCharacters.rawValue)
            NotificationCenter.default.post(name: .configurationDidChange, object: self, userInfo: ["key": Key.hintCharacters.rawValue])
        }
    }

    /// The font size for hint labels in points.
    /// Default: 11pt (Vimac's default)
    var hintTextSize: CGFloat {
        get {
            let size = defaults.double(forKey: Key.hintTextSize.rawValue)
            return size > 0 ? CGFloat(size) : Defaults.hintTextSize
        }
        set {
            defaults.set(Double(newValue), forKey: Key.hintTextSize.rawValue)
            NotificationCenter.default.post(name: .configurationDidChange, object: self, userInfo: ["key": Key.hintTextSize.rawValue])
        }
    }

    // MARK: - Hotkey Preferences

    /// Stored hotkey configurations as encoded data.
    var hotkeyConfigurationsData: Data? {
        get {
            defaults.data(forKey: Key.hotkeyConfigurations.rawValue)
        }
        set {
            defaults.set(newValue, forKey: Key.hotkeyConfigurations.rawValue)
        }
    }

    // MARK: - App Preferences

    /// Whether KeyNav should launch at system login.
    /// Default: false
    var launchAtLogin: Bool {
        get {
            defaults.bool(forKey: Key.launchAtLogin.rawValue)
        }
        set {
            defaults.set(newValue, forKey: Key.launchAtLogin.rawValue)
            NotificationCenter.default.post(name: .configurationDidChange, object: self, userInfo: ["key": Key.launchAtLogin.rawValue])
        }
    }

    /// Whether to show the menu bar icon.
    /// Default: true
    var showMenuBarIcon: Bool {
        get {
            if defaults.object(forKey: Key.showMenuBarIcon.rawValue) == nil {
                return Defaults.showMenuBarIcon
            }
            return defaults.bool(forKey: Key.showMenuBarIcon.rawValue)
        }
        set {
            defaults.set(newValue, forKey: Key.showMenuBarIcon.rawValue)
            NotificationCenter.default.post(name: .configurationDidChange, object: self, userInfo: ["key": Key.showMenuBarIcon.rawValue])
        }
    }

    // MARK: - Reset

    /// Resets all preferences to their default values.
    func resetToDefaults() {
        hintCharacters = Defaults.hintCharacters
        hintTextSize = Defaults.hintTextSize
        launchAtLogin = Defaults.launchAtLogin
        showMenuBarIcon = Defaults.showMenuBarIcon

        NotificationCenter.default.post(name: .configurationDidReset, object: self)
    }
}

// MARK: - Notifications

extension Notification.Name {
    /// Posted when a configuration value changes.
    /// The userInfo dictionary contains "key" with the configuration key that changed.
    static let configurationDidChange = Notification.Name("com.keynav.configurationDidChange")

    /// Posted when all configuration values are reset to defaults.
    static let configurationDidReset = Notification.Name("com.keynav.configurationDidReset")
}
