// Sources/KeyNav/Core/HoldKeyActivation.swift
import Foundation

/// Configuration for hold key activation
struct HoldKeyConfig {
    /// How long the key must be held to trigger activation (in seconds)
    let holdThreshold: TimeInterval

    /// The key code that triggers activation when held
    let activationKeyCode: UInt16

    init(holdThreshold: TimeInterval = 0.25, activationKeyCode: UInt16 = 49) {
        self.holdThreshold = holdThreshold
        self.activationKeyCode = activationKeyCode  // 49 = Space bar
    }
}

/// State of the hold key detection
enum HoldKeyState: Equatable {
    case idle
    case holding
}

/// Action to take after key release
enum HoldKeyAction: Equatable {
    case replayKeypress  // Released before threshold - replay the original keypress
    case activate        // Held long enough - activate the mode
    case abort           // Something went wrong (e.g., modifier changed)
}

/// State machine for hold-to-activate behavior
struct HoldKeyStateMachine {
    private(set) var state: HoldKeyState = .idle
    private(set) var heldKeyCode: UInt16?
    private var startModifiers: KeyModifiers = []

    private let config: HoldKeyConfig

    init(config: HoldKeyConfig = HoldKeyConfig()) {
        self.config = config
    }

    /// Called when a key is pressed
    mutating func keyDown(keyCode: UInt16, modifiers: KeyModifiers = []) {
        guard keyCode == config.activationKeyCode else { return }

        state = .holding
        heldKeyCode = keyCode
        startModifiers = modifiers
    }

    /// Called when a key is released
    /// - Returns: The action to take
    mutating func keyUp(keyCode: UInt16, heldDuration: TimeInterval, modifiers: KeyModifiers = []) -> HoldKeyAction {
        guard state == .holding, keyCode == heldKeyCode else {
            state = .idle
            heldKeyCode = nil
            return .abort
        }

        state = .idle
        heldKeyCode = nil

        // Check if modifiers changed during hold
        if modifiers != startModifiers {
            return .abort
        }

        // Check if held long enough
        if heldDuration >= config.holdThreshold {
            return .activate
        } else {
            return .replayKeypress
        }
    }

    /// Check if auto-repeat for a key should be suppressed
    func shouldSuppressRepeat(keyCode: UInt16) -> Bool {
        return state == .holding && keyCode == heldKeyCode
    }
}
