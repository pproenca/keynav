// Sources/KeyNav/Core/EnhancedUIActivator.swift
import Foundation

/// Manages AXEnhancedUserInterface activation for better accessibility support
struct EnhancedUIActivator {
    /// The accessibility attribute for enhanced UI
    let enhancedUIAttribute = "AXEnhancedUserInterface"

    /// Global activation state
    private(set) var isActivated = false

    /// Set of PIDs with enhanced UI activated
    private var activatedPIDs = Set<pid_t>()

    /// Set global activation state
    mutating func setActivated(_ activated: Bool) {
        isActivated = activated
    }

    /// Activate enhanced UI for a specific app
    mutating func activateForApp(pid: pid_t) {
        activatedPIDs.insert(pid)
    }

    /// Deactivate enhanced UI for a specific app
    mutating func deactivateForApp(pid: pid_t) {
        activatedPIDs.remove(pid)
    }

    /// Check if enhanced UI is activated for an app
    func isActivatedFor(pid: pid_t) -> Bool {
        return activatedPIDs.contains(pid)
    }

    /// Deactivate enhanced UI for all apps
    mutating func deactivateAll() {
        activatedPIDs.removeAll()
    }
}
