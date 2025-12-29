// Sources/KeyNav/Accessibility/PermissionManager.swift
import AppKit
import ApplicationServices

final class PermissionManager {
    static let shared = PermissionManager()

    private init() {}

    var isAccessibilityEnabled: Bool {
        AXIsProcessTrusted()
    }

    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    func pollForPermission(interval: TimeInterval = 1.0, completion: @escaping (Bool) -> Void) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.isAccessibilityEnabled {
                timer.invalidate()
                completion(true)
            }
        }
    }
}
