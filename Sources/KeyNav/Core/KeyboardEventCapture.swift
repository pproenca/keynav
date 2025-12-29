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
    func startCapturing()
    func stopCapturing()
}

/// Global event tap implementation that captures keyboard events from all apps
final class GlobalKeyboardEventCapture: KeyboardEventCapture {
    weak var delegate: KeyboardEventCaptureDelegate?
    private(set) var isCapturing = false

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    func startCapturing() {
        guard !isCapturing else { return }

        // Create event tap to intercept keyboard events globally
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        // We need to use a callback that can access self
        // Store self in a context that the callback can access
        let selfPtr = Unmanaged.passRetained(self).toOpaque()

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }

                let capture = Unmanaged<GlobalKeyboardEventCapture>.fromOpaque(refcon).takeUnretainedValue()

                // Handle tap disabled event
                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    if let tap = capture.eventTap {
                        CGEvent.tapEnable(tap: tap, enable: true)
                    }
                    return Unmanaged.passRetained(event)
                }

                guard type == .keyDown else {
                    return Unmanaged.passRetained(event)
                }

                let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

                // Get characters and modifiers from the event
                var chars: String? = nil
                var modifiers: KeyModifiers = []
                if let nsEvent = NSEvent(cgEvent: event) {
                    chars = nsEvent.characters
                    let nsModifiers = nsEvent.modifierFlags
                    if nsModifiers.contains(.shift) { modifiers.insert(.shift) }
                    if nsModifiers.contains(.control) { modifiers.insert(.control) }
                    if nsModifiers.contains(.option) { modifiers.insert(.option) }
                    if nsModifiers.contains(.command) { modifiers.insert(.command) }
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
            Unmanaged<GlobalKeyboardEventCapture>.fromOpaque(selfPtr).release()
            print("Failed to create event tap - accessibility permissions may be required")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        if let runLoopSource = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            isCapturing = true
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

        eventTap = nil
        runLoopSource = nil
        isCapturing = false
    }

    deinit {
        stopCapturing()
    }
}

/// Mock implementation for testing
final class MockKeyboardEventCapture: KeyboardEventCapture {
    weak var delegate: KeyboardEventCaptureDelegate?
    private(set) var isCapturing = false

    var startCapturingCallCount = 0
    var stopCapturingCallCount = 0

    func startCapturing() {
        startCapturingCallCount += 1
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
}
