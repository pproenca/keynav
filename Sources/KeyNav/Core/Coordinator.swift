// Sources/KeyNav/Core/Coordinator.swift
import AppKit

final class Coordinator {
    static let shared = Coordinator()

    private let hintMode = HintMode()
    private let scrollMode = ScrollMode()
    private let searchMode = SearchMode()

    private var currentMode: Mode?
    private var eventMonitor: Any?

    /// Tracks if setup completed successfully
    private(set) var isSetupComplete = false

    /// Callback when setup fails
    var onSetupFailed: ((String) -> Void)?

    /// Callback when a mode activation fails
    var onModeActivationFailed: ((ModeType, String) -> Void)?

    private init() {
        hintMode.delegate = self
        scrollMode.delegate = self
        searchMode.delegate = self

        // Listen for permission revocation
        PermissionManager.shared.onPermissionRevoked = { [weak self] in
            self?.handlePermissionRevoked()
        }
    }

    // MARK: - Setup

    func setup() {
        // Configure hotkey callbacks
        HotkeyManager.shared.onHintModeActivated = { [weak self] in
            self?.activateMode(.hint)
        }
        HotkeyManager.shared.onScrollModeActivated = { [weak self] in
            self?.activateMode(.scroll)
        }
        HotkeyManager.shared.onSearchModeActivated = { [weak self] in
            self?.activateMode(.search)
        }

        // Configure hotkey registration failure callback
        HotkeyManager.shared.onRegistrationFailed = { [weak self] mode, reason in
            self?.handleHotkeyRegistrationFailed(mode: mode, reason: reason)
        }

        // Setup hotkeys and check result
        let hotkeySuccess = HotkeyManager.shared.setup()

        if !hotkeySuccess {
            // At least one hotkey failed to register
            // AppStatus has already been updated by HotkeyManager
            // We continue anyway - the user can still use partial functionality
        }

        // Start permission monitoring
        PermissionManager.shared.performInitialCheck()
        PermissionManager.shared.startPermissionMonitoring()

        isSetupComplete = true

        // Report overall status
        if AppStatus.shared.hasAnyFailure {
            if let summary = AppStatus.shared.failureSummary {
                onSetupFailed?(summary)
            }
        }
    }

    // MARK: - Mode Activation

    func activateMode(_ type: ModeType) {
        // Check permission before activation
        guard PermissionManager.shared.isAccessibilityEnabled else {
            onModeActivationFailed?(type, "Accessibility permission is not granted")
            AppStatus.shared.showPermissionAlert()
            return
        }

        // Deactivate current mode if different
        if let current = currentMode, current.type != type {
            current.deactivate()
        }

        let mode: Mode
        switch type {
        case .hint:
            mode = hintMode
        case .scroll:
            mode = scrollMode
        case .search:
            mode = searchMode
        case .normal:
            // Normal mode has no special behavior, just deactivate
            deactivateCurrentMode()
            return
        }

        currentMode = mode
        mode.activate()
        startEventMonitor()
    }

    func deactivateCurrentMode() {
        currentMode?.deactivate()
        currentMode = nil
        stopEventMonitor()
    }

    // MARK: - Event Monitor

    private func startEventMonitor() {
        stopEventMonitor()

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, let mode = self.currentMode else { return event }

            if mode.handleKeyDown(event) {
                return nil  // Event handled
            }
            return event
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    // MARK: - Error Handling

    private func handleHotkeyRegistrationFailed(mode: HotkeyMode, reason: HotkeyFailureReason) {
        let modeName: String
        switch mode {
        case .hint: modeName = "Hint Mode"
        case .scroll: modeName = "Scroll Mode"
        case .search: modeName = "Search Mode"
        }

        let message = "\(modeName) shortcut could not be registered. \(reason.userMessage)"

        // Notify via callback
        onSetupFailed?(message)
    }

    private func handlePermissionRevoked() {
        // Deactivate any active mode
        deactivateCurrentMode()

        // Disable hotkeys (they won't work without permission anyway)
        HotkeyManager.shared.disable()

        // Show alert
        AppStatus.shared.showPermissionAlert()
    }

    // MARK: - Retry

    /// Retry setup after fixing issues (e.g., granting permission)
    func retrySetup() {
        if PermissionManager.shared.isAccessibilityEnabled {
            setup()
        }
    }

    /// Re-register hotkeys (useful after changing shortcuts)
    @discardableResult
    func refreshHotkeys() -> Bool {
        return HotkeyManager.shared.retryAllRegistrations()
    }
}

// MARK: - HintModeDelegate

extension Coordinator: HintModeDelegate {
    func hintModeDidDeactivate() {
        currentMode = nil
        stopEventMonitor()
    }

    func hintModeDidSelectElement(_ element: ActionableElement, clickType: ClickType) {
        // Could log or trigger custom actions based on click type
    }
}

// MARK: - ScrollModeDelegate

extension Coordinator: ScrollModeDelegate {
    func scrollModeDidDeactivate() {
        currentMode = nil
        stopEventMonitor()
    }
}

// MARK: - SearchModeDelegate

extension Coordinator: SearchModeDelegate {
    func searchModeDidDeactivate() {
        currentMode = nil
        stopEventMonitor()
    }

    func searchModeDidSelectElement(_ element: ActionableElement) {
        // Could log or trigger custom actions
    }
}
