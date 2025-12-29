// Sources/KeyNav/Core/CursorManager.swift
import AppKit

/// Manages cursor visibility during hint mode
/// Hides cursor to reduce visual clutter when showing hints
final class CursorManager {

    /// Shared instance for app-wide cursor management
    static let shared = CursorManager()

    /// Tracks whether the cursor is currently visible
    private(set) var isCursorVisible: Bool = true

    /// Hides the system cursor
    func hideCursor() {
        guard isCursorVisible else { return }
        NSCursor.hide()
        isCursorVisible = false
    }

    /// Shows the system cursor
    func showCursor() {
        guard !isCursorVisible else { return }
        NSCursor.unhide()
        isCursorVisible = true
    }
}
