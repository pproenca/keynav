// Sources/KeyNav/UI/ShortcutsPreferencesView.swift
import AppKit
import HotKey

/// Delegate protocol for ShortcutsPreferencesView actions
protocol ShortcutsPreferencesDelegate: AnyObject {
    func shortcutsPreferencesDidRetryShortcuts()
    func shortcutsPreferencesDidResetToDefaults()
    func shortcutsPreferencesShowAlert(title: String, message: String)
}

/// Configuration for a shortcut row
private struct ShortcutRowConfig {
    let label: String
    let config: HotkeyConfiguration
    let registered: Bool
    let accessibilityLabel: String
    let tag: Int
}

/// Builder class for the Shortcuts preferences tab view
final class ShortcutsPreferencesViewBuilder {
    weak var delegate: ShortcutsPreferencesDelegate?

    func createView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 350))

        var y: CGFloat = 290

        // Title
        y = addTitle(to: view, at: y)

        // Hint Mode row
        y = addHintModeRow(to: view, at: y)

        // Scroll Mode row
        y = addScrollModeRow(to: view, at: y)

        // Search Mode row
        y = addSearchModeRow(to: view, at: y)

        // Instructions
        y = addInstructions(to: view, at: y)

        // Action buttons
        addActionButtons(to: view, at: y)

        return view
    }

    // MARK: - View Building Helpers

    private func addTitle(to view: NSView, at y: CGFloat) -> CGFloat {
        let titleLabel = createLabel("Keyboard Shortcuts", bold: true)
        titleLabel.frame = NSRect(x: 20, y: y, width: 460, height: 20)
        view.addSubview(titleLabel)
        return y - 40
    }

    private func addHintModeRow(to view: NSView, at y: CGFloat) -> CGFloat {
        let rowConfig = ShortcutRowConfig(
            label: "Hint Mode:",
            config: HotkeyManager.shared.hintModeConfig,
            registered: HotkeyManager.shared.hintModeRegistered,
            accessibilityLabel: "Hint Mode",
            tag: 1
        )
        addShortcutRow(to: view, at: y, rowConfig: rowConfig)
        return y - 35
    }

    private func addScrollModeRow(to view: NSView, at y: CGFloat) -> CGFloat {
        let rowConfig = ShortcutRowConfig(
            label: "Scroll Mode:",
            config: HotkeyManager.shared.scrollModeConfig,
            registered: HotkeyManager.shared.scrollModeRegistered,
            accessibilityLabel: "Scroll Mode",
            tag: 2
        )
        addShortcutRow(to: view, at: y, rowConfig: rowConfig)
        return y - 35
    }

    private func addSearchModeRow(to view: NSView, at y: CGFloat) -> CGFloat {
        let rowConfig = ShortcutRowConfig(
            label: "Search Mode:",
            config: HotkeyManager.shared.searchModeConfig,
            registered: HotkeyManager.shared.searchModeRegistered,
            accessibilityLabel: "Search Mode",
            tag: 3
        )
        addShortcutRow(to: view, at: y, rowConfig: rowConfig)
        return y - 50
    }

    private func addShortcutRow(to view: NSView, at y: CGFloat, rowConfig: ShortcutRowConfig) {
        let labelView = createLabel(rowConfig.label)
        labelView.frame = NSRect(x: 20, y: y, width: 120, height: 25)
        view.addSubview(labelView)

        let shortcutField = createShortcutField(
            current: rowConfig.config.displayString,
            status: rowConfig.registered,
            accessibilityLabel: "\(rowConfig.accessibilityLabel) shortcut"
        )
        shortcutField.frame = NSRect(x: 150, y: y, width: 150, height: 25)
        shortcutField.tag = rowConfig.tag
        view.addSubview(shortcutField)

        let statusAccessibilityLabel: String
        if rowConfig.registered {
            statusAccessibilityLabel = "\(rowConfig.accessibilityLabel) registered"
        } else {
            statusAccessibilityLabel = "\(rowConfig.accessibilityLabel) not registered"
        }
        let statusIndicator = createStatusIndicator(
            rowConfig.registered,
            accessibilityLabel: statusAccessibilityLabel
        )
        statusIndicator.frame = NSRect(x: 310, y: y + 2, width: 20, height: 20)
        view.addSubview(statusIndicator)
    }

    private func addInstructions(to view: NSView, at y: CGFloat) -> CGFloat {
        let instructionText = "Click a shortcut field and press your desired key combination to change it."
        let instructionsLabel = createLabel(instructionText)
        instructionsLabel.frame = NSRect(x: 20, y: y, width: 460, height: 40)
        instructionsLabel.textColor = .secondaryLabelColor
        view.addSubview(instructionsLabel)
        return y - 40
    }

    private func addActionButtons(to view: NSView, at y: CGFloat) {
        let retryButton = NSButton(title: "Re-register All Shortcuts", target: self, action: #selector(retryShortcuts))
        retryButton.frame = NSRect(x: 20, y: y, width: 180, height: 30)
        retryButton.bezelStyle = .rounded
        view.addSubview(retryButton)

        let resetAction = #selector(resetShortcutsToDefaults)
        let resetButton = NSButton(title: "Reset to Defaults", target: self, action: resetAction)
        resetButton.frame = NSRect(x: 210, y: y, width: 140, height: 30)
        resetButton.bezelStyle = .rounded
        view.addSubview(resetButton)
    }

    // MARK: - UI Component Builders

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

    // MARK: - Actions

    @objc private func retryShortcuts() {
        delegate?.shortcutsPreferencesDidRetryShortcuts()
    }

    @objc private func resetShortcutsToDefaults() {
        delegate?.shortcutsPreferencesDidResetToDefaults()
    }
}
