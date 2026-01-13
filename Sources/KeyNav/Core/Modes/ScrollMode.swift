// Sources/KeyNav/Core/Modes/ScrollMode.swift
import AppKit
import ApplicationServices

protocol ScrollModeDelegate: AnyObject {
    func scrollModeDidDeactivate()
}

final class ScrollMode: Mode {
    let type: ModeType = .scroll
    private(set) var isActive = false

    weak var delegate: ScrollModeDelegate?

    private var overlayWindow: OverlayWindow?
    private var scrollIndicatorView: NSView?
    private var currentScrollArea: CGRect?

    private let scrollAmount: CGFloat = 50
    private let pageScrollAmount: CGFloat = 300
    private var waitingForSecondG = false

    func activate() {
        guard !isActive else { return }
        isActive = true

        setupOverlay()
        findScrollableArea()
    }

    func deactivate() {
        guard isActive else { return }
        isActive = false

        overlayWindow?.dismiss()
        overlayWindow = nil
        scrollIndicatorView = nil
        currentScrollArea = nil
        waitingForSecondG = false

        delegate?.scrollModeDidDeactivate()
    }

    func handleKeyDown(_ event: NSEvent) -> Bool {
        guard isActive else { return false }

        let keyCode = event.keyCode

        // Escape to cancel
        if keyCode == 53 {
            deactivate()
            return true
        }

        guard let chars = event.charactersIgnoringModifiers?.lowercased() else { return false }

        switch chars {
        case "h":
            scroll(deltaX: scrollAmount, deltaY: 0)
            return true
        case "j":
            scroll(deltaX: 0, deltaY: -scrollAmount)
            return true
        case "k":
            scroll(deltaX: 0, deltaY: scrollAmount)
            return true
        case "l":
            scroll(deltaX: -scrollAmount, deltaY: 0)
            return true
        case "d":
            scroll(deltaX: 0, deltaY: -pageScrollAmount)
            return true
        case "u":
            scroll(deltaX: 0, deltaY: pageScrollAmount)
            return true
        case "g":
            if waitingForSecondG {
                scrollToTop()
                waitingForSecondG = false
            } else if event.modifierFlags.contains(.shift) {
                scrollToBottom()
            } else {
                waitingForSecondG = true
                // Reset after delay if no second g
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.waitingForSecondG = false
                }
            }
            return true
        default:
            waitingForSecondG = false
            return false
        }
    }

    private func setupOverlay() {
        overlayWindow = OverlayWindow()
        overlayWindow?.show()
    }

    private func findScrollableArea() {
        // For now, use the focused window bounds
        guard let app = NSWorkspace.shared.frontmostApplication else { return }

        let axApp = AXUIElementCreateApplication(app.processIdentifier)

        guard let window = AXHelpers.getElement(from: axApp, attribute: kAXFocusedWindowAttribute as CFString),
              let frame = AXHelpers.getFrame(from: window) else { return }

        currentScrollArea = frame
        showScrollIndicator()
    }

    private func showScrollIndicator() {
        guard let area = currentScrollArea, let window = overlayWindow else { return }

        let indicatorView = NSView(frame: .zero)
        indicatorView.wantsLayer = true
        indicatorView.layer?.borderColor = NSColor.systemRed.cgColor
        indicatorView.layer?.borderWidth = 3
        indicatorView.layer?.cornerRadius = 4

        // Convert to screen coordinates
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let flippedY = screenHeight - area.origin.y - area.height

        indicatorView.frame = CGRect(
            x: area.origin.x,
            y: flippedY,
            width: area.width,
            height: area.height
        )

        window.contentView?.addSubview(indicatorView)
        scrollIndicatorView = indicatorView
    }

    private func scroll(deltaX: CGFloat, deltaY: CGFloat) {
        guard let area = currentScrollArea else { return }

        let scrollPoint = CGPoint(x: area.midX, y: area.midY)

        let scrollEvent = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: Int32(deltaY),
            wheel2: Int32(deltaX),
            wheel3: 0
        )

        scrollEvent?.location = scrollPoint
        scrollEvent?.post(tap: .cghidEventTap)
    }

    private func scrollToTop() {
        // Send multiple large scroll ups
        for _ in 0..<10 {
            scroll(deltaX: 0, deltaY: 1000)
        }
    }

    private func scrollToBottom() {
        // Send multiple large scroll downs
        for _ in 0..<10 {
            scroll(deltaX: 0, deltaY: -1000)
        }
    }
}
