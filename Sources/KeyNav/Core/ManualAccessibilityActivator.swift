// Sources/KeyNav/Core/ManualAccessibilityActivator.swift
import Foundation

/// Methods for manual accessibility activation
enum ActivationMethod: Equatable {
    case keyboard      // Use keyboard event simulation
    case accessibility // Use accessibility API
}

/// Fallback activation method when primary activation fails
struct ManualAccessibilityActivator {
    /// This is a fallback method
    let isFallbackMethod = true

    /// Supported activation methods
    let supportedMethods: Set<ActivationMethod> = [.keyboard, .accessibility]

    /// Preferred activation method
    let preferredMethod: ActivationMethod = .accessibility

    /// Current activation state
    private(set) var isActive = false

    /// Whether accessibility API is available
    private var accessibilityAvailable = true

    /// Current method being used
    var currentMethod: ActivationMethod {
        return accessibilityAvailable ? .accessibility : .keyboard
    }

    /// Set active state
    mutating func setActive(_ active: Bool) {
        isActive = active
    }

    /// Set accessibility availability
    mutating func setAccessibilityAvailable(_ available: Bool) {
        accessibilityAvailable = available
    }
}
