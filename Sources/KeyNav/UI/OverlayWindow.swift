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

        self.level = .statusBar  // Above normal windows but below alerts
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
        // Make key and order front to receive keyboard events
        makeKeyAndOrderFront(nil)
    }

    func dismiss() {
        orderOut(nil)
    }
}
