// Sources/KeyNav/Core/Modes/Mode.swift
import AppKit

enum ModeType {
    case hint
    case scroll
    case search
}

protocol Mode: AnyObject {
    var type: ModeType { get }
    var isActive: Bool { get }

    func activate()
    func deactivate()
    func handleKeyDown(_ event: NSEvent) -> Bool
}
