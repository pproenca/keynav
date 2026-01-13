// Sources/KeyNav/UI/DiagnosticPreferencesView.swift
import AppKit

/// Delegate protocol for DiagnosticPreferencesView actions
protocol DiagnosticPreferencesDelegate: AnyObject {
    func diagnosticPreferencesDidRequestPermission()
    func diagnosticPreferencesDidRefresh()
    func diagnosticPreferencesDidCopyInfo()
    func diagnosticPreferencesDidRetryAll()
}

/// Builder class for the Diagnostic preferences tab view
final class DiagnosticPreferencesViewBuilder {
    weak var delegate: DiagnosticPreferencesDelegate?

    func createView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 350))

        var y: CGFloat = 290

        // Title
        y = addTitle(to: view, at: y)

        // Permission Status row
        y = addPermissionRow(to: view, at: y)

        // Hint Mode Status row
        let hintStatus = AppStatus.shared.hintModeHotkeyStatus
        y = addStatusRow(to: view, at: y, label: "Hint Mode Shortcut:", status: hintStatus)

        // Scroll Mode Status row
        let scrollStatus = AppStatus.shared.scrollModeHotkeyStatus
        y = addStatusRow(to: view, at: y, label: "Scroll Mode Shortcut:", status: scrollStatus)

        // Search Mode Status row
        let searchStatus = AppStatus.shared.searchModeHotkeyStatus
        y = addStatusRow(to: view, at: y, label: "Search Mode Shortcut:", status: searchStatus)

        // Event Tap Status row
        y = addStatusRow(to: view, at: y, label: "Keyboard Capture:", status: AppStatus.shared.eventTapStatus)

        // Adjust y for extra spacing before buttons
        y -= 20

        // Action buttons
        addActionButtons(to: view, at: y)

        return view
    }

    // MARK: - View Building Helpers

    private func addTitle(to view: NSView, at y: CGFloat) -> CGFloat {
        let titleLabel = createLabel("System Status", bold: true)
        titleLabel.frame = NSRect(x: 20, y: y, width: 460, height: 20)
        view.addSubview(titleLabel)
        return y - 35
    }

    private func addPermissionRow(to view: NSView, at y: CGFloat) -> CGFloat {
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

        return y - 30
    }

    private func addStatusRow(to view: NSView, at y: CGFloat, label: String, status: SubsystemStatus) -> CGFloat {
        let labelView = createLabel(label)
        labelView.frame = NSRect(x: 20, y: y, width: 180, height: 25)
        view.addSubview(labelView)

        let statusView = createStatusLabel(status)
        statusView.frame = NSRect(x: 210, y: y, width: 270, height: 25)
        view.addSubview(statusView)

        return y - 30
    }

    private func addActionButtons(to view: NSView, at y: CGFloat) {
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

    // MARK: - Actions

    @objc private func requestPermission() {
        delegate?.diagnosticPreferencesDidRequestPermission()
    }

    @objc private func refreshDiagnostic() {
        delegate?.diagnosticPreferencesDidRefresh()
    }

    @objc private func copyDiagnosticInfo() {
        delegate?.diagnosticPreferencesDidCopyInfo()
    }

    @objc private func retryAll() {
        delegate?.diagnosticPreferencesDidRetryAll()
    }
}
