// Sources/KeyNav/UI/PreferencesWindowController.swift
import AppKit
import HotKey
import Carbon

class PreferencesWindowController: NSWindowController {
    private var tabView: NSTabView!

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

        tabView = NSTabView(frame: contentView.bounds)
        tabView.autoresizingMask = [.width, .height]
        tabView.setAccessibilityLabel("Preferences sections")

        // Shortcuts Tab
        let shortcutsTab = NSTabViewItem(identifier: "shortcuts")
        shortcutsTab.label = "Shortcuts"
        shortcutsTab.view = createShortcutsView()
        tabView.addTabViewItem(shortcutsTab)

        // Hints Tab
        let hintsTab = NSTabViewItem(identifier: "hints")
        hintsTab.label = "Hints"
        hintsTab.view = createHintsView()
        tabView.addTabViewItem(hintsTab)

        // Diagnostic Tab
        let diagnosticTab = NSTabViewItem(identifier: "diagnostic")
        diagnosticTab.label = "Diagnostic"
        diagnosticTab.view = createDiagnosticView()
        tabView.addTabViewItem(diagnosticTab)

        contentView.addSubview(tabView)
    }

    func showDiagnosticTab() {
        tabView.selectTabViewItem(withIdentifier: "diagnostic")
    }

    // MARK: - Shortcuts View

    private func createShortcutsView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 350))

        var y: CGFloat = 290

        // Title
        let titleLabel = createLabel("Keyboard Shortcuts", bold: true)
        titleLabel.frame = NSRect(x: 20, y: y, width: 460, height: 20)
        view.addSubview(titleLabel)
        y -= 40

        // Hint Mode
        let hintLabel = createLabel("Hint Mode:")
        hintLabel.frame = NSRect(x: 20, y: y, width: 120, height: 25)
        view.addSubview(hintLabel)

        let hintShortcut = createShortcutField(
            current: HotkeyManager.shared.hintModeConfig.displayString,
            status: HotkeyManager.shared.hintModeRegistered,
            accessibilityLabel: "Hint Mode shortcut"
        )
        hintShortcut.frame = NSRect(x: 150, y: y, width: 150, height: 25)
        hintShortcut.tag = 1
        view.addSubview(hintShortcut)

        let hintStatus = createStatusIndicator(
            HotkeyManager.shared.hintModeRegistered,
            accessibilityLabel: HotkeyManager.shared.hintModeRegistered ? "Hint Mode registered" : "Hint Mode not registered"
        )
        hintStatus.frame = NSRect(x: 310, y: y + 2, width: 20, height: 20)
        view.addSubview(hintStatus)

        y -= 35

        // Scroll Mode
        let scrollLabel = createLabel("Scroll Mode:")
        scrollLabel.frame = NSRect(x: 20, y: y, width: 120, height: 25)
        view.addSubview(scrollLabel)

        let scrollShortcut = createShortcutField(
            current: HotkeyManager.shared.scrollModeConfig.displayString,
            status: HotkeyManager.shared.scrollModeRegistered,
            accessibilityLabel: "Scroll Mode shortcut"
        )
        scrollShortcut.frame = NSRect(x: 150, y: y, width: 150, height: 25)
        scrollShortcut.tag = 2
        view.addSubview(scrollShortcut)

        let scrollStatus = createStatusIndicator(
            HotkeyManager.shared.scrollModeRegistered,
            accessibilityLabel: HotkeyManager.shared.scrollModeRegistered ? "Scroll Mode registered" : "Scroll Mode not registered"
        )
        scrollStatus.frame = NSRect(x: 310, y: y + 2, width: 20, height: 20)
        view.addSubview(scrollStatus)

        y -= 35

        // Search Mode
        let searchLabel = createLabel("Search Mode:")
        searchLabel.frame = NSRect(x: 20, y: y, width: 120, height: 25)
        view.addSubview(searchLabel)

        let searchShortcut = createShortcutField(
            current: HotkeyManager.shared.searchModeConfig.displayString,
            status: HotkeyManager.shared.searchModeRegistered,
            accessibilityLabel: "Search Mode shortcut"
        )
        searchShortcut.frame = NSRect(x: 150, y: y, width: 150, height: 25)
        searchShortcut.tag = 3
        view.addSubview(searchShortcut)

        let searchStatus = createStatusIndicator(
            HotkeyManager.shared.searchModeRegistered,
            accessibilityLabel: HotkeyManager.shared.searchModeRegistered ? "Search Mode registered" : "Search Mode not registered"
        )
        searchStatus.frame = NSRect(x: 310, y: y + 2, width: 20, height: 20)
        view.addSubview(searchStatus)

        y -= 50

        // Instructions
        let instructionsLabel = createLabel("Click a shortcut field and press your desired key combination to change it.")
        instructionsLabel.frame = NSRect(x: 20, y: y, width: 460, height: 40)
        instructionsLabel.textColor = .secondaryLabelColor
        view.addSubview(instructionsLabel)

        y -= 40

        // Retry button
        let retryButton = NSButton(title: "Re-register All Shortcuts", target: self, action: #selector(retryShortcuts))
        retryButton.frame = NSRect(x: 20, y: y, width: 180, height: 30)
        retryButton.bezelStyle = .rounded
        view.addSubview(retryButton)

        // Reset to defaults button
        let resetButton = NSButton(title: "Reset to Defaults", target: self, action: #selector(resetShortcutsToDefaults))
        resetButton.frame = NSRect(x: 210, y: y, width: 140, height: 30)
        resetButton.bezelStyle = .rounded
        view.addSubview(resetButton)

        return view
    }

    private func createShortcutField(current: String, status: Bool, accessibilityLabel: String) -> NSTextField {
        let field = ShortcutTextField(frame: .zero)
        field.stringValue = current
        field.isEditable = true
        field.isBezeled = true
        field.bezelStyle = .roundedBezel
        field.alignment = .center
        field.font = NSFont.systemFont(ofSize: 13)
        field.setAccessibilityLabel(accessibilityLabel)
        field.setAccessibilityRoleDescription("Press to record a new keyboard shortcut")
        return field
    }

    private func createStatusIndicator(_ isOperational: Bool, accessibilityLabel: String) -> NSImageView {
        let imageView = NSImageView()
        let imageName = isOperational ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
        let accessibilityDesc = isOperational ? "Status: registered" : "Status: not registered"
        let color: NSColor = isOperational ? .systemGreen : .systemOrange
        imageView.image = NSImage(systemSymbolName: imageName, accessibilityDescription: accessibilityDesc)
        imageView.contentTintColor = color
        imageView.setAccessibilityLabel(accessibilityLabel)
        return imageView
    }

    @objc private func retryShortcuts() {
        let success = HotkeyManager.shared.retryAllRegistrations()
        if success {
            showAlert(title: "Success", message: "All shortcuts registered successfully.")
        } else {
            showAlert(title: "Some Shortcuts Failed", message: "Not all shortcuts could be registered. Check for conflicts with other applications.")
        }
        refreshShortcutsView()
    }

    @objc private func resetShortcutsToDefaults() {
        // Reset to default shortcuts
        _ = HotkeyManager.shared.updateHintModeHotkey(key: .space, modifiers: [.command, .shift])
        _ = HotkeyManager.shared.updateScrollModeHotkey(key: .j, modifiers: [.command, .shift])
        _ = HotkeyManager.shared.updateSearchModeHotkey(key: .slash, modifiers: [.command, .shift])

        refreshShortcutsView()
        showAlert(title: "Reset Complete", message: "Shortcuts have been reset to defaults.")
    }

    private func refreshShortcutsView() {
        // Refresh the shortcuts tab
        if let shortcutsItem = tabView.tabViewItem(at: 0).view {
            shortcutsItem.subviews.forEach { $0.removeFromSuperview() }
        }
        tabView.tabViewItem(at: 0).view = createShortcutsView()
    }

    // MARK: - Hints View

    private func getHintCharacters() -> String {
        Configuration.shared.hintCharacters
    }

    private func setHintCharacters(_ chars: String) {
        Configuration.shared.hintCharacters = chars
    }

    private func getHintTextSize() -> CGFloat {
        Configuration.shared.hintTextSize
    }

    private func setHintTextSize(_ size: CGFloat) {
        Configuration.shared.hintTextSize = size
    }

    private func createHintsView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 350))

        var y: CGFloat = 290

        // Title
        let titleLabel = createLabel("Hint Settings", bold: true)
        titleLabel.frame = NSRect(x: 20, y: y, width: 460, height: 20)
        view.addSubview(titleLabel)
        y -= 40

        // Character Set
        let charLabel = createLabel("Hint Characters:")
        charLabel.frame = NSRect(x: 20, y: y, width: 120, height: 25)
        view.addSubview(charLabel)

        let charField = NSTextField(frame: NSRect(x: 150, y: y, width: 200, height: 25))
        charField.stringValue = getHintCharacters()
        charField.tag = 10
        charField.target = self
        charField.action = #selector(hintCharactersChanged(_:))
        charField.setAccessibilityLabel("Hint characters")
        charField.setAccessibilityRoleDescription("Characters used for keyboard hint labels")
        view.addSubview(charField)

        y -= 30

        let charHint = createLabel("Characters used for hint labels (e.g., 'sadfjklewcmpgh')")
        charHint.frame = NSRect(x: 150, y: y, width: 300, height: 20)
        charHint.textColor = .secondaryLabelColor
        charHint.font = NSFont.systemFont(ofSize: 11)
        view.addSubview(charHint)

        y -= 40

        // Text Size
        let sizeLabel = createLabel("Hint Text Size:")
        sizeLabel.frame = NSRect(x: 20, y: y, width: 120, height: 25)
        view.addSubview(sizeLabel)

        let sizeSlider = NSSlider(frame: NSRect(x: 150, y: y, width: 150, height: 25))
        sizeSlider.minValue = 8
        sizeSlider.maxValue = 20
        sizeSlider.doubleValue = Double(getHintTextSize())
        sizeSlider.target = self
        sizeSlider.action = #selector(hintSizeChanged(_:))
        sizeSlider.setAccessibilityLabel("Hint text size")
        sizeSlider.setAccessibilityValue("\(Int(getHintTextSize())) points")
        view.addSubview(sizeSlider)

        let sizeValueLabel = createLabel("\(Int(getHintTextSize())) pt")
        sizeValueLabel.frame = NSRect(x: 310, y: y, width: 50, height: 25)
        sizeValueLabel.tag = 11
        view.addSubview(sizeValueLabel)

        return view
    }

    @objc private func hintCharactersChanged(_ sender: NSTextField) {
        let newChars = sender.stringValue
        if !newChars.isEmpty && HintCharacterPrefs.isValid(newChars) {
            setHintCharacters(newChars)
        }
    }

    @objc private func hintSizeChanged(_ sender: NSSlider) {
        let newSize = CGFloat(sender.doubleValue)
        setHintTextSize(newSize)

        // Update the label
        if let hintsView = tabView.tabViewItem(at: 1).view,
           let sizeLabel = hintsView.viewWithTag(11) as? NSTextField {
            sizeLabel.stringValue = "\(Int(newSize)) pt"
        }
    }

    // MARK: - Diagnostic View

    private func createDiagnosticView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 350))

        var y: CGFloat = 290

        // Title
        let titleLabel = createLabel("System Status", bold: true)
        titleLabel.frame = NSRect(x: 20, y: y, width: 460, height: 20)
        view.addSubview(titleLabel)
        y -= 35

        // Permission Status
        let permLabel = createLabel("Accessibility Permission:")
        permLabel.frame = NSRect(x: 20, y: y, width: 180, height: 25)
        view.addSubview(permLabel)

        let permStatus = createStatusLabel(AppStatus.shared.permissionStatus)
        permStatus.frame = NSRect(x: 210, y: y, width: 200, height: 25)
        view.addSubview(permStatus)

        let permButton = NSButton(title: "Request", target: self, action: #selector(requestPermission))
        permButton.frame = NSRect(x: 420, y: y, width: 60, height: 25)
        permButton.bezelStyle = .rounded
        permButton.isEnabled = !PermissionManager.shared.isAccessibilityEnabled
        view.addSubview(permButton)

        y -= 30

        // Hint Mode Status
        let hintLabel = createLabel("Hint Mode Shortcut:")
        hintLabel.frame = NSRect(x: 20, y: y, width: 180, height: 25)
        view.addSubview(hintLabel)

        let hintStatus = createStatusLabel(AppStatus.shared.hintModeHotkeyStatus)
        hintStatus.frame = NSRect(x: 210, y: y, width: 270, height: 25)
        view.addSubview(hintStatus)

        y -= 30

        // Scroll Mode Status
        let scrollLabel = createLabel("Scroll Mode Shortcut:")
        scrollLabel.frame = NSRect(x: 20, y: y, width: 180, height: 25)
        view.addSubview(scrollLabel)

        let scrollStatus = createStatusLabel(AppStatus.shared.scrollModeHotkeyStatus)
        scrollStatus.frame = NSRect(x: 210, y: y, width: 270, height: 25)
        view.addSubview(scrollStatus)

        y -= 30

        // Search Mode Status
        let searchLabel = createLabel("Search Mode Shortcut:")
        searchLabel.frame = NSRect(x: 20, y: y, width: 180, height: 25)
        view.addSubview(searchLabel)

        let searchStatus = createStatusLabel(AppStatus.shared.searchModeHotkeyStatus)
        searchStatus.frame = NSRect(x: 210, y: y, width: 270, height: 25)
        view.addSubview(searchStatus)

        y -= 30

        // Event Tap Status
        let tapLabel = createLabel("Keyboard Capture:")
        tapLabel.frame = NSRect(x: 20, y: y, width: 180, height: 25)
        view.addSubview(tapLabel)

        let tapStatus = createStatusLabel(AppStatus.shared.eventTapStatus)
        tapStatus.frame = NSRect(x: 210, y: y, width: 270, height: 25)
        view.addSubview(tapStatus)

        y -= 50

        // Actions
        let refreshButton = NSButton(title: "Refresh Status", target: self, action: #selector(refreshDiagnostic))
        refreshButton.frame = NSRect(x: 20, y: y, width: 120, height: 30)
        refreshButton.bezelStyle = .rounded
        view.addSubview(refreshButton)

        let copyButton = NSButton(title: "Copy Diagnostic Info", target: self, action: #selector(copyDiagnosticInfo))
        copyButton.frame = NSRect(x: 150, y: y, width: 150, height: 30)
        copyButton.bezelStyle = .rounded
        view.addSubview(copyButton)

        let retryAllButton = NSButton(title: "Retry All", target: self, action: #selector(retryAll))
        retryAllButton.frame = NSRect(x: 310, y: y, width: 80, height: 30)
        retryAllButton.bezelStyle = .rounded
        view.addSubview(retryAllButton)

        return view
    }

    private func createStatusLabel(_ status: SubsystemStatus) -> NSTextField {
        let label = NSTextField(labelWithString: "")

        switch status {
        case .unknown:
            label.stringValue = "Unknown"
            label.textColor = .secondaryLabelColor
        case .operational:
            label.stringValue = "Operational"
            label.textColor = .systemGreen
        case .failed(let reason):
            label.stringValue = "Failed: \(reason)"
            label.textColor = .systemRed
        case .disabled:
            label.stringValue = "Disabled"
            label.textColor = .secondaryLabelColor
        }

        return label
    }

    @objc private func requestPermission() {
        PermissionManager.shared.openAccessibilityPreferences()
    }

    @objc private func refreshDiagnostic() {
        // Refresh the diagnostic tab
        tabView.tabViewItem(at: 2).view = createDiagnosticView()
    }

    @objc private func copyDiagnosticInfo() {
        let info = AppStatus.shared.diagnosticInfo()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(info, forType: .string)

        showAlert(title: "Copied", message: "Diagnostic information copied to clipboard.")
    }

    @objc private func retryAll() {
        Coordinator.shared.retrySetup()
        refreshDiagnostic()
        refreshShortcutsView()
    }

    // MARK: - Helpers

    private func createLabel(_ text: String, bold: Bool = false) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        if bold {
            label.font = NSFont.boldSystemFont(ofSize: 13)
        }
        return label
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
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
        if keyCode == 56 || keyCode == 60 || keyCode == 55 || keyCode == 54 ||
           keyCode == 58 || keyCode == 61 || keyCode == 59 || keyCode == 62 {
            return
        }

        let modifiers = event.modifierFlags

        // Require at least one modifier
        guard modifiers.contains(.command) || modifiers.contains(.control) ||
              modifiers.contains(.option) || modifiers.contains(.shift) else {
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
