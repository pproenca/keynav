// Sources/KeyNav/Core/HotkeyStorage.swift
import Foundation

/// Helper class for persisting hotkey configurations
final class HotkeyStorage {
    /// Load saved hotkey configurations from storage
    static func loadConfigurations() -> [String: HotkeyConfiguration]? {
        guard let data = Configuration.shared.hotkeyConfigurationsData else { return nil }

        do {
            return try JSONDecoder().decode([String: HotkeyConfiguration].self, from: data)
        } catch {
            // Return nil if loading fails, caller will use defaults
            return nil
        }
    }

    /// Save hotkey configurations to storage
    static func saveConfigurations(
        hint: HotkeyConfiguration,
        scroll: HotkeyConfiguration,
        search: HotkeyConfiguration
    ) {
        let configs: [String: HotkeyConfiguration] = [
            "hint": hint,
            "scroll": scroll,
            "search": search,
        ]

        do {
            let data = try JSONEncoder().encode(configs)
            Configuration.shared.hotkeyConfigurationsData = data
        } catch {
            // Silently fail - not critical
        }
    }
}
