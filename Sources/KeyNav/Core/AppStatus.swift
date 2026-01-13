// Sources/KeyNav/Core/AppStatus.swift
import AppKit
import Combine

/// Represents the status of a subsystem
enum SubsystemStatus: Equatable {
    case unknown
    case operational
    case failed(reason: String)
    case disabled

    var isOperational: Bool {
        if case .operational = self { return true }
        return false
    }

    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }

    var failureReason: String? {
        if case .failed(let reason) = self { return reason }
        return nil
    }
}

/// Hotkey registration failure reasons
enum HotkeyFailureReason {
    case shortcutConflict(shortcut: String)
    case permissionDenied
    case systemError(code: Int)
    case unknown

    var userMessage: String {
        switch self {
        case .shortcutConflict(let shortcut):
            return "The shortcut \(shortcut) is already in use by another application."
        case .permissionDenied:
            return "Accessibility permission is required to register global shortcuts."
        case .systemError(let code):
            return "Failed to register shortcut (error code: \(code))."
        case .unknown:
            return "Failed to register shortcut for an unknown reason."
        }
    }
}

/// Event tap failure reasons
enum EventTapFailureReason {
    case permissionDenied
    case systemError
    case disabledByTimeout
    case disabledByUserInput

    var userMessage: String {
        switch self {
        case .permissionDenied:
            return "Accessibility permission is required to capture keyboard events."
        case .systemError:
            return "Failed to create keyboard event monitor."
        case .disabledByTimeout:
            return "Keyboard event monitor was disabled due to timeout."
        case .disabledByUserInput:
            return "Keyboard event monitor was disabled by system."
        }
    }
}

/// Central status tracker for all app subsystems
final class AppStatus: ObservableObject {
    static let shared = AppStatus()

    // MARK: - Published Status Properties

    @Published private(set) var permissionStatus: SubsystemStatus = .unknown
    @Published private(set) var hintModeHotkeyStatus: SubsystemStatus = .unknown
    @Published private(set) var scrollModeHotkeyStatus: SubsystemStatus = .unknown
    @Published private(set) var searchModeHotkeyStatus: SubsystemStatus = .unknown
    @Published private(set) var eventTapStatus: SubsystemStatus = .unknown

    // MARK: - Computed Properties

    var isFullyOperational: Bool {
        permissionStatus.isOperational && hintModeHotkeyStatus.isOperational && scrollModeHotkeyStatus.isOperational
            && searchModeHotkeyStatus.isOperational
    }

    var hasAnyFailure: Bool {
        permissionStatus.isFailed || hintModeHotkeyStatus.isFailed || scrollModeHotkeyStatus.isFailed
            || searchModeHotkeyStatus.isFailed || eventTapStatus.isFailed
    }

    var failureSummary: String? {
        var failures: [String] = []

        if let reason = permissionStatus.failureReason {
            failures.append("Permission: \(reason)")
        }
        if let reason = hintModeHotkeyStatus.failureReason {
            failures.append("Hint Mode Shortcut: \(reason)")
        }
        if let reason = scrollModeHotkeyStatus.failureReason {
            failures.append("Scroll Mode Shortcut: \(reason)")
        }
        if let reason = searchModeHotkeyStatus.failureReason {
            failures.append("Search Mode Shortcut: \(reason)")
        }
        if let reason = eventTapStatus.failureReason {
            failures.append("Keyboard Capture: \(reason)")
        }

        return failures.isEmpty ? nil : failures.joined(separator: "\n")
    }

    // MARK: - Callbacks for UI notification

    var onStatusChange: ((AppStatus) -> Void)?
    var onCriticalFailure: ((String, String) -> Void)?  // (title, message)

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Observe all status changes
        Publishers.CombineLatest4(
            $permissionStatus,
            $hintModeHotkeyStatus,
            $scrollModeHotkeyStatus,
            $searchModeHotkeyStatus
        )
        .sink { [weak self] _ in
            guard let self = self else { return }
            self.onStatusChange?(self)
        }
        .store(in: &cancellables)
    }

    // MARK: - Status Update Methods

    func updatePermissionStatus(_ status: SubsystemStatus) {
        DispatchQueue.main.async {
            self.permissionStatus = status
            if case .failed(let reason) = status {
                self.notifyCriticalFailure(title: "Permission Required", message: reason)
            }
        }
    }

    func updateHintModeHotkeyStatus(_ status: SubsystemStatus) {
        DispatchQueue.main.async {
            self.hintModeHotkeyStatus = status
            if case .failed(let reason) = status {
                self.notifyCriticalFailure(title: "Hint Mode Shortcut Failed", message: reason)
            }
        }
    }

    func updateScrollModeHotkeyStatus(_ status: SubsystemStatus) {
        DispatchQueue.main.async {
            self.scrollModeHotkeyStatus = status
            if case .failed(let reason) = status {
                self.notifyCriticalFailure(title: "Scroll Mode Shortcut Failed", message: reason)
            }
        }
    }

    func updateSearchModeHotkeyStatus(_ status: SubsystemStatus) {
        DispatchQueue.main.async {
            self.searchModeHotkeyStatus = status
            if case .failed(let reason) = status {
                self.notifyCriticalFailure(title: "Search Mode Shortcut Failed", message: reason)
            }
        }
    }

    func updateEventTapStatus(_ status: SubsystemStatus) {
        DispatchQueue.main.async {
            self.eventTapStatus = status
            if case .failed(let reason) = status {
                self.notifyCriticalFailure(title: "Keyboard Capture Failed", message: reason)
            }
        }
    }

    // MARK: - Alert Display

    private func notifyCriticalFailure(title: String, message: String) {
        onCriticalFailure?(title, message)
    }

    /// Shows a user-visible alert for a failure
    func showAlert(title: String, message: String, showPreferences: Bool = true) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning

            if showPreferences {
                alert.addButton(withTitle: "Open Preferences")
                alert.addButton(withTitle: "Dismiss")
            } else {
                alert.addButton(withTitle: "OK")
            }

            let response = alert.runModal()

            if showPreferences && response == .alertFirstButtonReturn {
                // Notify to open preferences
                NotificationCenter.default.post(name: .openPreferences, object: nil)
            }
        }
    }

    /// Shows an alert specifically for permission issues
    func showPermissionAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = """
                KeyNav needs Accessibility permission to detect UI elements \
                and respond to keyboard shortcuts.

                Please grant permission in System Settings > Privacy & Security > Accessibility.
                """
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Later")

            let response = alert.runModal()

            if response == .alertFirstButtonReturn {
                PermissionManager.shared.openAccessibilityPreferences()
            }
        }
    }

    // MARK: - Diagnostic Information

    func diagnosticInfo() -> String {
        var info = "KeyNav Diagnostic Report\n"
        info += "========================\n\n"
        info += "Permission Status: \(statusDescription(permissionStatus))\n"
        info += "Hint Mode Hotkey: \(statusDescription(hintModeHotkeyStatus))\n"
        info += "Scroll Mode Hotkey: \(statusDescription(scrollModeHotkeyStatus))\n"
        info += "Search Mode Hotkey: \(statusDescription(searchModeHotkeyStatus))\n"
        info += "Event Tap: \(statusDescription(eventTapStatus))\n"
        info += "\nmacOS Version: \(ProcessInfo.processInfo.operatingSystemVersionString)\n"
        info += "App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")\n"
        return info
    }

    private func statusDescription(_ status: SubsystemStatus) -> String {
        switch status {
        case .unknown:
            return "Unknown"
        case .operational:
            return "Operational"
        case .failed(let reason):
            return "Failed - \(reason)"
        case .disabled:
            return "Disabled"
        }
    }

    // MARK: - Reset

    func reset() {
        permissionStatus = .unknown
        hintModeHotkeyStatus = .unknown
        scrollModeHotkeyStatus = .unknown
        searchModeHotkeyStatus = .unknown
        eventTapStatus = .unknown
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openPreferences = Notification.Name("com.keynav.openPreferences")
    static let appStatusChanged = Notification.Name("com.keynav.appStatusChanged")
}
