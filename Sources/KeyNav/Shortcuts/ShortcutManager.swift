// Sources/KeyNav/Shortcuts/ShortcutManager.swift
import Foundation
import AppKit
import HotKey

final class ShortcutManager {
    static let shared = ShortcutManager()

    private var shortcuts: [CustomShortcut] = []
    private var activeHotkeys: [UUID: HotKey] = [:]
    private let accessibilityEngine = AccessibilityEngine()

    private let storageURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let keynavDir = appSupport.appendingPathComponent("KeyNav", isDirectory: true)
        try? FileManager.default.createDirectory(at: keynavDir, withIntermediateDirectories: true)
        return keynavDir.appendingPathComponent("shortcuts.json")
    }()

    private init() {
        loadShortcuts()
    }

    var allShortcuts: [CustomShortcut] {
        shortcuts
    }

    func addShortcut(_ shortcut: CustomShortcut) {
        shortcuts.append(shortcut)
        registerHotkey(for: shortcut)
        saveShortcuts()
    }

    func removeShortcut(id: UUID) {
        shortcuts.removeAll { $0.id == id }
        activeHotkeys[id] = nil
        saveShortcuts()
    }

    func updateShortcut(_ shortcut: CustomShortcut) {
        if let index = shortcuts.firstIndex(where: { $0.id == shortcut.id }) {
            shortcuts[index] = shortcut
            registerHotkey(for: shortcut)
            saveShortcuts()
        }
    }

    private func registerHotkey(for shortcut: CustomShortcut) {
        // Remove existing hotkey
        activeHotkeys[shortcut.id] = nil

        // Parse modifiers
        var modifiers: NSEvent.ModifierFlags = []
        for mod in shortcut.hotkeyModifiers {
            switch mod.lowercased() {
            case "command": modifiers.insert(.command)
            case "shift": modifiers.insert(.shift)
            case "option": modifiers.insert(.option)
            case "control": modifiers.insert(.control)
            default: break
            }
        }

        // Create hotkey (simplified - in real app would map keyCode to Key enum)
        guard let key = Key(carbonKeyCode: UInt32(shortcut.hotkeyCode)) else { return }

        let hotkey = HotKey(key: key, modifiers: modifiers)
        hotkey.keyDownHandler = { [weak self] in
            self?.executeShortcut(shortcut)
        }

        activeHotkeys[shortcut.id] = hotkey
    }

    private func executeShortcut(_ shortcut: CustomShortcut) {
        // Bring app to front
        let runningApps = NSWorkspace.shared.runningApplications
        guard let app = runningApps.first(where: { $0.bundleIdentifier == shortcut.appBundleId }) else {
            // App not running
            return
        }

        app.activate(options: .activateIgnoringOtherApps)

        // Wait for app to activate, then find and click element
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.findAndClickElement(shortcut: shortcut)
        }
    }

    private func findAndClickElement(shortcut: CustomShortcut) {
        accessibilityEngine.getActionableElements { [weak self] elements in
            guard let self = self else { return }

            // Try to find matching element
            let sig = shortcut.elementSignature

            // Primary: match by identifier
            if let identifier = sig.identifier,
               let element = elements.first(where: { $0.identifier == identifier }) {
                self.performAction(shortcut.action, on: element)
                return
            }

            // Secondary: match by label + role
            if let element = elements.first(where: { $0.label == sig.label && $0.role == sig.role }) {
                self.performAction(shortcut.action, on: element)
                return
            }

            // Fallback: fuzzy match on label
            let matcher = FuzzyMatcher()
            if let element = elements.first(where: { matcher.matches(query: sig.label, in: $0.label) }) {
                self.performAction(shortcut.action, on: element)
            }
        }
    }

    private func performAction(_ action: ClickAction, on element: ActionableElement) {
        switch action {
        case .single:
            accessibilityEngine.performClick(on: element)
        case .double:
            accessibilityEngine.performDoubleClick(on: element)
        case .right:
            accessibilityEngine.performRightClick(on: element)
        }
    }

    private func loadShortcuts() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }

        do {
            let data = try Data(contentsOf: storageURL)
            shortcuts = try JSONDecoder().decode([CustomShortcut].self, from: data)

            for shortcut in shortcuts {
                registerHotkey(for: shortcut)
            }
        } catch {
            print("Failed to load shortcuts: \(error)")
        }
    }

    private func saveShortcuts() {
        do {
            let data = try JSONEncoder().encode(shortcuts)
            try data.write(to: storageURL)
        } catch {
            print("Failed to save shortcuts: \(error)")
        }
    }
}
