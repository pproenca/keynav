// Sources/KeyNav/UI/OverlayWindow.swift
import AppKit

/// Overlay window that can capture keyboard events without activating the app.
/// Uses NSPanel with .nonactivatingPanel to receive key events while keeping
/// the underlying application active.
final class OverlayWindow: NSPanel {

    init() {
        let screenFrame = NSScreen.main?.frame ?? .zero

        super.init(
            contentRect: screenFrame,
            styleMask: .nonactivatingPanel,  // Key: allows keyboard capture without activating
            backing: .buffered,
            defer: false
        )

        // Use a level above popUpMenu (101) so hints appear above dropdown menus
        // CGWindowLevelForKey(.overlayWindow) = 102
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.overlayWindow)))
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = true  // Mouse events pass through to underlying app
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    // Critical: allows the panel to become key and receive keyboard events
    override var canBecomeKey: Bool {
        return true
    }

    func show() {
        // Update frame to current screen size
        if let screenFrame = NSScreen.main?.frame {
            setFrame(screenFrame, display: true)
        }
        // Use orderFrontRegardless to show window without stealing focus
        // This keeps menus open while displaying the overlay
        orderFrontRegardless()
    }

    func dismiss() {
        orderOut(nil)
    }
}
