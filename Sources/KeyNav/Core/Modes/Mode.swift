// Sources/KeyNav/Core/Modes/Mode.swift
import AppKit

enum ModeType: String, Equatable {
    case normal
    case hint
    case scroll
    case search
}

/// Result of handling a key input in a mode
enum KeyInputResult: Equatable {
    /// The input was consumed by the mode
    case consumed
    /// The input should pass through to the system
    case passThrough
    /// The mode should exit
    case exitMode
}

protocol Mode: AnyObject {
    var type: ModeType { get }
    var isActive: Bool { get }

    func activate()
    func deactivate()
    func handleKeyDown(_ event: NSEvent) -> Bool
}

// MARK: - Mode Controller Protocol

/// Protocol for mode controllers with delegate support
protocol ModeControllerProtocol: AnyObject {
    /// Whether the mode is currently active
    var isActive: Bool { get }

    /// The type of this mode
    var modeType: ModeType { get }

    /// Delegate for mode events
    var delegate: ModeControllerDelegate? { get set }

    /// Activate the mode
    func activate()

    /// Deactivate the mode
    func deactivate()

    /// Handle key input
    /// - Parameters:
    ///   - keyCode: The key code
    ///   - modifiers: The modifier keys
    /// - Returns: The result of handling the input
    func handleKeyInput(keyCode: UInt16, modifiers: KeyModifiers) -> KeyInputResult
}

// MARK: - Mode Controller Delegate

/// Delegate for receiving mode controller events
protocol ModeControllerDelegate: AnyObject {
    /// Called when a mode is activated
    func modeDidActivate(_ controller: ModeControllerProtocol)

    /// Called when a mode is deactivated
    func modeDidDeactivate(_ controller: ModeControllerProtocol)
}

// MARK: - Mode Manager

/// Manages switching between modes
struct ModeManager {
    private var controllers: [ModeType: ModeControllerProtocol] = [:]
    private(set) var currentMode: ModeType?

    /// Register a mode controller
    mutating func register(controller: ModeControllerProtocol, for mode: ModeType) {
        controllers[mode] = controller
    }

    /// Get the controller for a mode
    func controller(for mode: ModeType) -> ModeControllerProtocol? {
        controllers[mode]
    }

    /// Switch to a different mode
    mutating func switchTo(mode: ModeType) {
        // Deactivate current mode
        if let currentMode = currentMode,
           let currentController = controllers[currentMode] {
            currentController.deactivate()
        }

        // Activate new mode
        if let newController = controllers[mode] {
            newController.activate()
        }

        currentMode = mode
    }

    /// Deactivate all modes
    mutating func deactivateAll() {
        for (_, controller) in controllers {
            controller.deactivate()
        }
        currentMode = nil
    }
}
