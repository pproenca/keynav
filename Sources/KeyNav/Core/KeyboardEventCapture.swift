// Sources/KeyNav/Core/KeyboardEventCapture.swift
import AppKit
import Carbon.HIToolbox

/// Protocol for keyboard event capture - allows testing without actual system events
protocol KeyboardEventCaptureDelegate: AnyObject {
    /// Called when a key event is captured. Return true to consume the event.
    func keyboardEventCapture(_ capture: KeyboardEventCapture, didReceiveKeyDown keyCode: UInt16, characters: String?, modifiers: KeyModifiers) -> Bool
}

/// Protocol for keyboard event capture - enables mocking in tests
protocol KeyboardEventCapture: AnyObject {
    var delegate: KeyboardEventCaptureDelegate? { get set }
    var isCapturing: Bool { get }

    /// Called when event tap creation fails
    var onEventTapFailed: ((EventTapFailureReason) -> Void)? { get set }

    /// Called when event tap is re-enabled after being disabled
    var onEventTapReEnabled: (() -> Void)? { get set }

    func startCapturing()
    func stopCapturing()
}

/// Global event tap implementation that captures keyboard events from all apps
final class GlobalKeyboardEventCapture: KeyboardEventCapture {
    weak var delegate: KeyboardEventCaptureDelegate?
    private(set) var isCapturing = false

    /// Called when event tap creation fails
    var onEventTapFailed: ((EventTapFailureReason) -> Void)?

    /// Called when event tap is re-enabled after being disabled
    var onEventTapReEnabled: (() -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var selfPtr: UnsafeMutableRawPointer?

    /// Number of times we've attempted to re-enable the tap
    private var reEnableAttempts = 0
    private let maxReEnableAttempts = 3

    func startCapturing() {
        guard !isCapturing else { return }

        // Reset re-enable counter on fresh start
        reEnableAttempts = 0

        // Create event tap to intercept keyboard events globally
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        // Store self in a context that the callback can access
        selfPtr = Unmanaged.passRetained(self).toOpaque()

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }

                let capture = Unmanaged<GlobalKeyboardEventCapture>.fromOpaque(refcon).takeUnretainedValue()

                // Handle tap disabled events
                if type == .tapDisabledByTimeout {
                    capture.handleTapDisabled(reason: .disabledByTimeout)
                    return Unmanaged.passRetained(event)
                }

                if type == .tapDisabledByUserInput {
                    capture.handleTapDisabled(reason: .disabledByUserInput)
                    return Unmanaged.passRetained(event)
                }

                guard type == .keyDown else {
                    return Unmanaged.passRetained(event)
                }

                let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

                // Get characters and modifiers from the event
                var chars: String? = nil
                var modifiers: KeyModifiers = []

                // Try to convert CGEvent to NSEvent for character extraction
                if let nsEvent = NSEvent(cgEvent: event) {
                    chars = nsEvent.characters
                    let nsModifiers = nsEvent.modifierFlags
                    if nsModifiers.contains(.shift) { modifiers.insert(.shift) }
                    if nsModifiers.contains(.control) { modifiers.insert(.control) }
                    if nsModifiers.contains(.option) { modifiers.insert(.option) }
                    if nsModifiers.contains(.command) { modifiers.insert(.command) }
                } else {
                    // Fallback: extract modifiers directly from CGEvent flags
                    let flags = event.flags
                    if flags.contains(.maskShift) { modifiers.insert(.shift) }
                    if flags.contains(.maskControl) { modifiers.insert(.control) }
                    if flags.contains(.maskAlternate) { modifiers.insert(.option) }
                    if flags.contains(.maskCommand) { modifiers.insert(.command) }

                    // Note: Character extraction failed, but we can still process the key code
                    // This can happen with non-US keyboard layouts
                }

                // Ask delegate if we should consume this event
                if let delegate = capture.delegate {
                    let shouldConsume = delegate.keyboardEventCapture(capture, didReceiveKeyDown: keyCode, characters: chars, modifiers: modifiers)
                    if shouldConsume {
                        return nil // Consume the event
                    }
                }

                return Unmanaged.passRetained(event)
            },
            userInfo: selfPtr
        )

        guard let eventTap = eventTap else {
            // Clean up the retained reference since we're not using it
            if let ptr = selfPtr {
                Unmanaged<GlobalKeyboardEventCapture>.fromOpaque(ptr).release()
                selfPtr = nil
            }

            // Determine failure reason
            let reason: EventTapFailureReason
            if !AXIsProcessTrusted() {
                reason = .permissionDenied
            } else {
                reason = .systemError
            }

            // Notify via callback
            onEventTapFailed?(reason)

            // Update AppStatus
            AppStatus.shared.updateEventTapStatus(.failed(reason: reason.userMessage))

            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        if let runLoopSource = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            isCapturing = true

            // Update AppStatus
            AppStatus.shared.updateEventTapStatus(.operational)
        } else {
            // Failed to create run loop source
            if let ptr = selfPtr {
                Unmanaged<GlobalKeyboardEventCapture>.fromOpaque(ptr).release()
                selfPtr = nil
            }
            onEventTapFailed?(.systemError)
            AppStatus.shared.updateEventTapStatus(.failed(reason: EventTapFailureReason.systemError.userMessage))
        }
    }

    func stopCapturing() {
        guard isCapturing else { return }

        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        // Release the retained reference
        if let ptr = selfPtr {
            Unmanaged<GlobalKeyboardEventCapture>.fromOpaque(ptr).release()
            selfPtr = nil
        }

        eventTap = nil
        runLoopSource = nil
        isCapturing = false
    }

    /// Handle event tap being disabled by system
    private func handleTapDisabled(reason: EventTapFailureReason) {
        guard let tap = eventTap else { return }

        reEnableAttempts += 1

        if reEnableAttempts <= maxReEnableAttempts {
            // Try to re-enable the tap
            CGEvent.tapEnable(tap: tap, enable: true)

            // Check if re-enable succeeded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self, let tap = self.eventTap else { return }

                if CGEvent.tapIsEnabled(tap: tap) {
                    self.onEventTapReEnabled?()
                    AppStatus.shared.updateEventTapStatus(.operational)
                } else {
                    // Re-enable failed
                    self.onEventTapFailed?(reason)
                    AppStatus.shared.updateEventTapStatus(.failed(reason: reason.userMessage))
                }
            }
        } else {
            // Too many re-enable attempts, report failure
            onEventTapFailed?(reason)
            AppStatus.shared.updateEventTapStatus(.failed(reason: reason.userMessage))
        }
    }

    deinit {
        stopCapturing()
    }
}

/// Mock implementation for testing
final class MockKeyboardEventCapture: KeyboardEventCapture {
    weak var delegate: KeyboardEventCaptureDelegate?
    private(set) var isCapturing = false

    var onEventTapFailed: ((EventTapFailureReason) -> Void)?
    var onEventTapReEnabled: (() -> Void)?

    var startCapturingCallCount = 0
    var stopCapturingCallCount = 0

    /// Set this to simulate a failure on startCapturing
    var shouldFailOnStart = false
    var failureReason: EventTapFailureReason = .systemError

    func startCapturing() {
        startCapturingCallCount += 1

        if shouldFailOnStart {
            onEventTapFailed?(failureReason)
            return
        }

        isCapturing = true
    }

    func stopCapturing() {
        stopCapturingCallCount += 1
        isCapturing = false
    }

    /// Simulate a key event for testing
    func simulateKeyDown(keyCode: UInt16, characters: String?, modifiers: KeyModifiers = []) -> Bool {
        return delegate?.keyboardEventCapture(self, didReceiveKeyDown: keyCode, characters: characters, modifiers: modifiers) ?? false
    }

    /// Simulate event tap being disabled
    func simulateTapDisabled(reason: EventTapFailureReason) {
        onEventTapFailed?(reason)
    }
}
