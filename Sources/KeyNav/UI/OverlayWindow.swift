// Sources/KeyNav/UI/OverlayWindow.swift
import AppKit

final class OverlayWindow: NSWindow {

    init() {
        let screenFrame = NSScreen.main?.frame ?? .zero

        super.init(
            contentRect: screenFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        self.level = .screenSaver
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    func show() {
        // Update frame to current screen size
        if let screenFrame = NSScreen.main?.frame {
            setFrame(screenFrame, display: true)
        }
        orderFrontRegardless()
    }

    func dismiss() {
        orderOut(nil)
    }
}
