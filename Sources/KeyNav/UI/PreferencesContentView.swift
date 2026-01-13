// Sources/KeyNav/UI/PreferencesContentView.swift
import AppKit
import HotKey

/// Protocol for handling preference changes.
protocol PreferencesContentViewDelegate: AnyObject {
    func preferencesDidChangeHintCharacters(_ characters: String)
    func preferencesDidChangeHintSize(_ size: CGFloat)
    func preferencesDidRequestRetryShortcuts()
    func preferencesDidRequestResetShortcuts()
    func preferencesDidRequestRequestPermission()
    func preferencesDidRequestRefreshDiagnostic()
    func preferencesDidRequestCopyDiagnostic()
    func preferencesDidRequestRetryAll()
}

/// Stack-based view for the Shortcuts preferences tab.
final class ShortcutsPreferencesView: NSView {
    weak var delegate: PreferencesContentViewDelegate?

    private lazy var mainStack: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        // Title
        let titleLabel = createTitleLabel("Keyboard Shortcuts")
        mainStack.addArrangedSubview(titleLabel)
        mainStack.setCustomSpacing(20, after: titleLabel)

        // Hint Mode row
        mainStack.addArrangedSubview(createHotkeyRow(
            label: "Hint Mode:",
            shortcut: HotkeyManager.shared.hintModeConfig.displayString,
            isRegistered: HotkeyManager.shared.hintModeRegistered,
            tag: 1,
            accessibilityLabel: "Hint Mode shortcut"
        ))

        // Scroll Mode row
        mainStack.addArrangedSubview(createHotkeyRow(
            label: "Scroll Mode:",
            shortcut: HotkeyManager.shared.scrollModeConfig.displayString,
            isRegistered: HotkeyManager.shared.scrollModeRegistered,
            tag: 2,
            accessibilityLabel: "Scroll Mode shortcut"
        ))

        // Search Mode row
        mainStack.addArrangedSubview(createHotkeyRow(
            label: "Search Mode:",
            shortcut: HotkeyManager.shared.searchModeConfig.displayString,
            isRegistered: HotkeyManager.shared.searchModeRegistered,
            tag: 3,
            accessibilityLabel: "Search Mode shortcut"
        ))

        mainStack.setCustomSpacing(20, after: mainStack.arrangedSubviews.last!)

        // Instructions
        let instructionsLabel = NSTextField(wrappingLabelWithString: "Click a shortcut field and press your desired key combination to change it.")
        instructionsLabel.textColor = .secondaryLabelColor
        mainStack.addArrangedSubview(instructionsLabel)
        mainStack.setCustomSpacing(20, after: instructionsLabel)

        // Buttons
        let buttonsStack = NSStackView()
        buttonsStack.orientation = .horizontal
        buttonsStack.spacing = 12

        let retryButton = NSButton(title: "Re-register All Shortcuts", target: self, action: #selector(retryShortcuts))
        retryButton.bezelStyle = .rounded
        buttonsStack.addArrangedSubview(retryButton)

        let resetButton = NSButton(title: "Reset to Defaults", target: self, action: #selector(resetShortcuts))
        resetButton.bezelStyle = .rounded
        buttonsStack.addArrangedSubview(resetButton)

        mainStack.addArrangedSubview(buttonsStack)
    }

    private func createTitleLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }

    private func createHotkeyRow(
        label: String,
        shortcut: String,
        isRegistered: Bool,
        tag: Int,
        accessibilityLabel: String
    ) -> NSView {
        let rowStack = NSStackView()
        rowStack.orientation = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .centerY

        let labelField = NSTextField(labelWithString: label)
        labelField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        labelField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        rowStack.addArrangedSubview(labelField)

        let shortcutField = ShortcutTextField(frame: .zero)
        shortcutField.stringValue = shortcut
        shortcutField.isEditable = true
        shortcutField.isBezeled = true
        shortcutField.bezelStyle = .roundedBezel
        shortcutField.alignment = .center
        shortcutField.font = .systemFont(ofSize: 13)
        shortcutField.tag = tag
        shortcutField.setAccessibilityLabel(accessibilityLabel)
        shortcutField.setAccessibilityRoleDescription("Press to record a new keyboard shortcut")
        shortcutField.widthAnchor.constraint(equalToConstant: 150).isActive = true
        rowStack.addArrangedSubview(shortcutField)

        let statusDesc = isRegistered ? "Status: registered" : "Status: not registered"
        let statusImage = NSImage(
            systemSymbolName: isRegistered ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
            accessibilityDescription: statusDesc
        )
        let statusView = NSImageView(image: statusImage ?? NSImage())
        statusView.contentTintColor = isRegistered ? .systemGreen : .systemOrange
        statusView.setAccessibilityLabel(isRegistered ? "\(label) registered" : "\(label) not registered")
        rowStack.addArrangedSubview(statusView)

        return rowStack
    }

    @objc private func retryShortcuts() {
        delegate?.preferencesDidRequestRetryShortcuts()
    }

    @objc private func resetShortcuts() {
        delegate?.preferencesDidRequestResetShortcuts()
    }
}

/// Stack-based view for the Hints preferences tab.
final class HintsPreferencesView: NSView {
    weak var delegate: PreferencesContentViewDelegate?

    private var sizeValueLabel: NSTextField?
    private var sizeSlider: NSSlider?

    private lazy var mainStack: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        // Title
        let titleLabel = createTitleLabel("Hint Settings")
        mainStack.addArrangedSubview(titleLabel)
        mainStack.setCustomSpacing(20, after: titleLabel)

        // Characters row
        mainStack.addArrangedSubview(createCharactersRow())

        // Size row
        mainStack.addArrangedSubview(createSizeRow())
    }

    private func createTitleLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }

    private func createCharactersRow() -> NSView {
        let containerStack = NSStackView()
        containerStack.orientation = .vertical
        containerStack.alignment = .leading
        containerStack.spacing = 4

        let rowStack = NSStackView()
        rowStack.orientation = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .centerY

        let label = NSTextField(labelWithString: "Hint Characters:")
        label.widthAnchor.constraint(equalToConstant: 120).isActive = true
        rowStack.addArrangedSubview(label)

        let charField = NSTextField()
        charField.stringValue = getHintCharacters()
        charField.target = self
        charField.action = #selector(hintCharactersChanged(_:))
        charField.setAccessibilityLabel("Hint characters")
        charField.setAccessibilityRoleDescription("Characters used for keyboard hint labels")
        charField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        rowStack.addArrangedSubview(charField)

        containerStack.addArrangedSubview(rowStack)

        let hintLabel = NSTextField(labelWithString: "Characters used for hint labels (e.g., 'sadfjklewcmpgh')")
        hintLabel.textColor = .secondaryLabelColor
        hintLabel.font = .systemFont(ofSize: 11)
        containerStack.addArrangedSubview(hintLabel)

        return containerStack
    }

    private func createSizeRow() -> NSView {
        let rowStack = NSStackView()
        rowStack.orientation = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .centerY

        let label = NSTextField(labelWithString: "Hint Text Size:")
        label.widthAnchor.constraint(equalToConstant: 120).isActive = true
        rowStack.addArrangedSubview(label)

        let slider = NSSlider()
        slider.minValue = 8
        slider.maxValue = 20
        slider.doubleValue = Double(getHintTextSize())
        slider.target = self
        slider.action = #selector(hintSizeChanged(_:))
        slider.setAccessibilityLabel("Hint text size")
        slider.setAccessibilityValue("\(Int(getHintTextSize())) points")
        slider.widthAnchor.constraint(equalToConstant: 150).isActive = true
        rowStack.addArrangedSubview(slider)
        sizeSlider = slider

        let valueLabel = NSTextField(labelWithString: "\(Int(getHintTextSize())) pt")
        valueLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        rowStack.addArrangedSubview(valueLabel)
        sizeValueLabel = valueLabel

        return rowStack
    }

    private func getHintCharacters() -> String {
        Configuration.shared.hintCharacters
    }

    private func getHintTextSize() -> CGFloat {
        Configuration.shared.hintTextSize
    }

    @objc private func hintCharactersChanged(_ sender: NSTextField) {
        let newChars = sender.stringValue
        if !newChars.isEmpty {
            delegate?.preferencesDidChangeHintCharacters(newChars)
        }
    }

    @objc private func hintSizeChanged(_ sender: NSSlider) {
        let newSize = CGFloat(sender.doubleValue)
        sizeValueLabel?.stringValue = "\(Int(newSize)) pt"
        sizeSlider?.setAccessibilityValue("\(Int(newSize)) points")
        delegate?.preferencesDidChangeHintSize(newSize)
    }
}

/// Stack-based view for the Diagnostic preferences tab.
final class DiagnosticPreferencesView: NSView {
    weak var delegate: PreferencesContentViewDelegate?

    private lazy var mainStack: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        // Title
        let titleLabel = createTitleLabel("System Status")
        mainStack.addArrangedSubview(titleLabel)
        mainStack.setCustomSpacing(16, after: titleLabel)

        // Status rows
        mainStack.addArrangedSubview(createStatusRow(
            label: "Accessibility Permission:",
            status: AppStatus.shared.permissionStatus,
            showRequestButton: !PermissionManager.shared.isAccessibilityEnabled
        ))

        mainStack.addArrangedSubview(createStatusRow(
            label: "Hint Mode Shortcut:",
            status: AppStatus.shared.hintModeHotkeyStatus
        ))

        mainStack.addArrangedSubview(createStatusRow(
            label: "Scroll Mode Shortcut:",
            status: AppStatus.shared.scrollModeHotkeyStatus
        ))

        mainStack.addArrangedSubview(createStatusRow(
            label: "Search Mode Shortcut:",
            status: AppStatus.shared.searchModeHotkeyStatus
        ))

        mainStack.addArrangedSubview(createStatusRow(
            label: "Keyboard Capture:",
            status: AppStatus.shared.eventTapStatus
        ))

        mainStack.setCustomSpacing(24, after: mainStack.arrangedSubviews.last!)

        // Buttons
        let buttonsStack = NSStackView()
        buttonsStack.orientation = .horizontal
        buttonsStack.spacing = 12

        let refreshButton = NSButton(title: "Refresh Status", target: self, action: #selector(refreshDiagnostic))
        refreshButton.bezelStyle = .rounded
        buttonsStack.addArrangedSubview(refreshButton)

        let copyButton = NSButton(title: "Copy Diagnostic Info", target: self, action: #selector(copyDiagnostic))
        copyButton.bezelStyle = .rounded
        buttonsStack.addArrangedSubview(copyButton)

        let retryButton = NSButton(title: "Retry All", target: self, action: #selector(retryAll))
        retryButton.bezelStyle = .rounded
        buttonsStack.addArrangedSubview(retryButton)

        mainStack.addArrangedSubview(buttonsStack)
    }

    private func createTitleLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }

    private func createStatusRow(
        label: String,
        status: SubsystemStatus,
        showRequestButton: Bool = false
    ) -> NSView {
        let rowStack = NSStackView()
        rowStack.orientation = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .centerY

        let labelField = NSTextField(labelWithString: label)
        labelField.widthAnchor.constraint(equalToConstant: 180).isActive = true
        rowStack.addArrangedSubview(labelField)

        let statusLabel = NSTextField(labelWithString: "")
        switch status {
        case .unknown:
            statusLabel.stringValue = "Unknown"
            statusLabel.textColor = .secondaryLabelColor
        case .operational:
            statusLabel.stringValue = "Operational"
            statusLabel.textColor = .systemGreen
        case .failed(let reason):
            statusLabel.stringValue = "Failed: \(reason)"
            statusLabel.textColor = .systemRed
        case .disabled:
            statusLabel.stringValue = "Disabled"
            statusLabel.textColor = .secondaryLabelColor
        }
        statusLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        rowStack.addArrangedSubview(statusLabel)

        if showRequestButton {
            let requestButton = NSButton(title: "Request", target: self, action: #selector(requestPermission))
            requestButton.bezelStyle = .rounded
            rowStack.addArrangedSubview(requestButton)
        }

        return rowStack
    }

    @objc private func requestPermission() {
        delegate?.preferencesDidRequestRequestPermission()
    }

    @objc private func refreshDiagnostic() {
        delegate?.preferencesDidRequestRefreshDiagnostic()
    }

    @objc private func copyDiagnostic() {
        delegate?.preferencesDidRequestCopyDiagnostic()
    }

    @objc private func retryAll() {
        delegate?.preferencesDidRequestRetryAll()
    }
}
