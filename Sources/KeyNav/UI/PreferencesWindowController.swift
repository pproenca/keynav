// Sources/KeyNav/UI/PreferencesWindowController.swift
import AppKit
import Carbon
import HotKey

class PreferencesWindowController: NSWindowController {
    private var tabView: NSTabView?

    private var shortcutsViewBuilder: ShortcutsPreferencesViewBuilder?
    private var hintsViewBuilder: HintsPreferencesViewBuilder?
    private var diagnosticViewBuilder: DiagnosticPreferencesViewBuilder?

    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "KeyNav Preferences"
        window.center()

        super.init(window: window)

        setupUI()
    }

    required init?(coder: NSCoder) {
        // This controller is always created programmatically, not from a storyboard
        return nil
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        // Configure window accessibility
        window?.setAccessibilityLabel("KeyNav Preferences")
        window?.setAccessibilityRole(.window)

        let tabs = NSTabView(frame: contentView.bounds)
        tabs.autoresizingMask = [.width, .height]
        tabs.setAccessibilityLabel("Preferences sections")

        // Shortcuts Tab
        let shortcutsTab = NSTabViewItem(identifier: "shortcuts")
        shortcutsTab.label = "Shortcuts"
        let shortcutsBuilder = ShortcutsPreferencesViewBuilder()
        shortcutsBuilder.delegate = self
        shortcutsViewBuilder = shortcutsBuilder
        shortcutsTab.view = shortcutsBuilder.createView()
        tabs.addTabViewItem(shortcutsTab)

        // Hints Tab
        let hintsTab = NSTabViewItem(identifier: "hints")
        hintsTab.label = "Hints"
        let hintsBuilder = HintsPreferencesViewBuilder()
        hintsBuilder.delegate = self
        hintsViewBuilder = hintsBuilder
        hintsTab.view = hintsBuilder.createView()
        tabs.addTabViewItem(hintsTab)

        // Diagnostic Tab
        let diagnosticTab = NSTabViewItem(identifier: "diagnostic")
        diagnosticTab.label = "Diagnostic"
        let diagnosticBuilder = DiagnosticPreferencesViewBuilder()
        diagnosticBuilder.delegate = self
        diagnosticViewBuilder = diagnosticBuilder
        diagnosticTab.view = diagnosticBuilder.createView()
        tabs.addTabViewItem(diagnosticTab)

        contentView.addSubview(tabs)
        tabView = tabs
    }

    func showDiagnosticTab() {
        tabView?.selectTabViewItem(withIdentifier: "diagnostic")
    }

    private func refreshShortcutsView() {
        if let shortcutsItem = tabView?.tabViewItem(at: 0).view {
            for subview in shortcutsItem.subviews {
                subview.removeFromSuperview()
            }
        }
        tabView?.tabViewItem(at: 0).view = shortcutsViewBuilder?.createView()
    }

    private func refreshDiagnosticView() {
        tabView?.tabViewItem(at: 2).view = diagnosticViewBuilder?.createView()
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - ShortcutsPreferencesDelegate

extension PreferencesWindowController: ShortcutsPreferencesDelegate {
    func shortcutsPreferencesDidRetryShortcuts() {
        let success = HotkeyManager.shared.retryAllRegistrations()
        if success {
            showAlert(title: "Success", message: "All shortcuts registered successfully.")
        } else {
            let failedMessage =
                "Not all shortcuts could be registered. " + "Check for conflicts with other applications."
            showAlert(title: "Some Shortcuts Failed", message: failedMessage)
        }
        refreshShortcutsView()
    }

    func shortcutsPreferencesDidResetToDefaults() {
        // Reset to default shortcuts
        _ = HotkeyManager.shared.updateHintModeHotkey(key: .space, modifiers: [.command, .shift])
        _ = HotkeyManager.shared.updateScrollModeHotkey(key: .j, modifiers: [.command, .shift])
        _ = HotkeyManager.shared.updateSearchModeHotkey(key: .slash, modifiers: [.command, .shift])

        refreshShortcutsView()
        showAlert(title: "Reset Complete", message: "Shortcuts have been reset to defaults.")
    }

    func shortcutsPreferencesShowAlert(title: String, message: String) {
        showAlert(title: title, message: message)
    }
}

// MARK: - HintsPreferencesDelegate

extension PreferencesWindowController: HintsPreferencesDelegate {
    func hintsPreferencesDidChangeCharacters(_ characters: String) {
        Configuration.shared.hintCharacters = characters
    }

    func hintsPreferencesDidChangeTextSize(_ size: CGFloat) {
        Configuration.shared.hintTextSize = size
    }
}

// MARK: - DiagnosticPreferencesDelegate

extension PreferencesWindowController: DiagnosticPreferencesDelegate {
    func diagnosticPreferencesDidRequestPermission() {
        PermissionManager.shared.openAccessibilityPreferences()
    }

    func diagnosticPreferencesDidRefresh() {
        refreshDiagnosticView()
    }

    func diagnosticPreferencesDidCopyInfo() {
        let info = AppStatus.shared.diagnosticInfo()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(info, forType: .string)

        showAlert(title: "Copied", message: "Diagnostic information copied to clipboard.")
    }

    func diagnosticPreferencesDidRetryAll() {
        Coordinator.shared.retrySetup()
        refreshDiagnosticView()
        refreshShortcutsView()
    }
}

// MARK: - Shortcut Text Field

/// Custom text field that captures keyboard shortcuts
class ShortcutTextField: NSTextField {
    private var isRecording = false

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            isRecording = true
            stringValue = "Press shortcut..."
        }
        return result
    }

    override func resignFirstResponder() -> Bool {
        isRecording = false
        return super.resignFirstResponder()
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        // Ignore modifier-only presses
        let keyCode = event.keyCode
        if keyCode == 56 || keyCode == 60 || keyCode == 55 || keyCode == 54 || keyCode == 58 || keyCode == 61
            || keyCode == 59 || keyCode == 62
        {
            return
        }

        let modifiers = event.modifierFlags

        // Require at least one modifier
        guard
            modifiers.contains(.command) || modifiers.contains(.control) || modifiers.contains(.option)
                || modifiers.contains(.shift)
        else {
            return
        }

        // Update the shortcut
        if let key = Key(carbonKeyCode: UInt32(keyCode)) {
            let result: HotkeyRegistrationResult

            switch tag {
            case 1:
                result = HotkeyManager.shared.updateHintModeHotkey(key: key, modifiers: modifiers)
            case 2:
                result = HotkeyManager.shared.updateScrollModeHotkey(key: key, modifiers: modifiers)
            case 3:
                result = HotkeyManager.shared.updateSearchModeHotkey(key: key, modifiers: modifiers)
            default:
                return
            }

            switch result {
            case .success:
                // Update display
                updateDisplayForTag(tag, key: key, modifiers: modifiers)
            case .failed(let reason):
                showFailureAlert(reason: reason)
                // Restore previous value
                restorePreviousValue()
            }
        }

        window?.makeFirstResponder(nil)
    }

    private func updateDisplayForTag(_ tag: Int, key: Key, modifiers: NSEvent.ModifierFlags) {
        var parts: [String] = []
        if modifiers.contains(.command) { parts.append("⌘") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.control) { parts.append("⌃") }
        parts.append(key.description.uppercased())
        stringValue = parts.joined()
    }

    private func restorePreviousValue() {
        switch tag {
        case 1:
            stringValue = HotkeyManager.shared.hintModeConfig.displayString
        case 2:
            stringValue = HotkeyManager.shared.scrollModeConfig.displayString
        case 3:
            stringValue = HotkeyManager.shared.searchModeConfig.displayString
        default:
            break
        }
    }

    private func showFailureAlert(reason: HotkeyFailureReason) {
        let alert = NSAlert()
        alert.messageText = "Shortcut Registration Failed"
        alert.informativeText = reason.userMessage
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
