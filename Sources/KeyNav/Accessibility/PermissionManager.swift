// Sources/KeyNav/Accessibility/PermissionManager.swift
import AppKit
import ApplicationServices

/// Result of permission polling
enum PermissionPollResult {
    case granted
    case denied
    case timeout
}

final class PermissionManager {
    static let shared = PermissionManager()

    /// Timer for permission polling
    private var pollTimer: Timer?

    /// Timer for permission monitoring (after initial grant)
    private var monitorTimer: Timer?

    /// Callback when permission status changes after initial setup
    var onPermissionRevoked: (() -> Void)?

    /// Last known permission state
    private var lastKnownPermissionState = false

    private init() {}

    // MARK: - Permission Status

    var isAccessibilityEnabled: Bool {
        AXIsProcessTrusted()
    }

    // MARK: - Request Permission

    /// Request accessibility permission with system prompt
    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    // MARK: - Open System Preferences

    private static let accessibilityPreferencesURLString =
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

    /// Opens the Accessibility section of System Settings/Preferences
    func openAccessibilityPreferences() {
        guard let url = URL(string: Self.accessibilityPreferencesURLString) else { return }
        NSWorkspace.shared.open(url)
    }

    // MARK: - Poll for Permission

    /// Poll for permission with timeout support
    /// - Parameters:
    ///   - interval: How often to check (default: 1 second)
    ///   - timeout: Maximum time to wait before giving up (default: 60 seconds, nil for no timeout)
    ///   - onGranted: Called when permission is granted
    ///   - onTimeout: Called when timeout expires without permission being granted
    func pollForPermission(
        interval: TimeInterval = 1.0,
        timeout: TimeInterval? = 60.0,
        onGranted: @escaping () -> Void,
        onTimeout: (() -> Void)? = nil
    ) {
        stopPolling()

        let startTime = Date()

        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            // Check if permission granted
            if self.isAccessibilityEnabled {
                timer.invalidate()
                self.pollTimer = nil
                self.lastKnownPermissionState = true

                // Update AppStatus
                AppStatus.shared.updatePermissionStatus(.operational)

                // Start monitoring for revocation
                self.startPermissionMonitoring()

                onGranted()
                return
            }

            // Check for timeout
            if let timeout = timeout {
                let elapsed = Date().timeIntervalSince(startTime)
                if elapsed >= timeout {
                    timer.invalidate()
                    self.pollTimer = nil

                    // Update AppStatus
                    let reason = "Permission not granted within \(Int(timeout)) seconds"
                    AppStatus.shared.updatePermissionStatus(.failed(reason: reason))

                    onTimeout?()
                    return
                }
            }
        }
    }

    /// Legacy method for backward compatibility
    func pollForPermission(interval: TimeInterval = 1.0, completion: @escaping (Bool) -> Void) {
        pollForPermission(
            interval: interval,
            timeout: nil,
            onGranted: { completion(true) },
            onTimeout: nil
        )
    }

    /// Stop any active polling
    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    // MARK: - Permission Monitoring

    /// Start monitoring for permission revocation (call after permission is granted)
    func startPermissionMonitoring() {
        stopPermissionMonitoring()

        lastKnownPermissionState = isAccessibilityEnabled

        // Check every 5 seconds if permission is still granted
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            let currentState = self.isAccessibilityEnabled

            // Detect permission revocation
            if self.lastKnownPermissionState && !currentState {
                // Permission was revoked
                AppStatus.shared.updatePermissionStatus(.failed(reason: "Accessibility permission was revoked"))
                self.onPermissionRevoked?()
            }

            self.lastKnownPermissionState = currentState
        }
    }

    /// Stop monitoring for permission changes
    func stopPermissionMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
    }

    // MARK: - Initial Check

    /// Perform initial permission check and update AppStatus
    func performInitialCheck() {
        if isAccessibilityEnabled {
            lastKnownPermissionState = true
            AppStatus.shared.updatePermissionStatus(.operational)
            startPermissionMonitoring()
        } else {
            lastKnownPermissionState = false
            AppStatus.shared.updatePermissionStatus(.failed(reason: "Accessibility permission required"))
        }
    }

    // MARK: - Retry

    /// Attempt to request permission again
    func retryPermissionRequest() {
        requestAccessibilityPermission()
    }

    deinit {
        stopPolling()
        stopPermissionMonitoring()
    }
}
