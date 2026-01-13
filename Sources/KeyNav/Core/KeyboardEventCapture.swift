// Sources/KeyNav/Core/KeyboardEventCapture.swift
import AppKit
import Carbon.HIToolbox

/// Protocol for keyboard event capture - allows testing without actual system events
protocol KeyboardEventCaptureDelegate: AnyObject {
    /// Called when a key event is captured. Return true to consume the event.
    func keyboardEventCapture(
        _ capture: KeyboardEventCapture,
        didReceiveKeyDown keyCode: UInt16,
        characters: String?,
        modifiers: KeyModifiers
    ) -> Bool
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

    // MARK: - Modifier Extraction Helpers

    private static func extractModifiers(from nsEvent: NSEvent) -> KeyModifiers {
        var modifiers: KeyModifiers = []
        let nsModifiers = nsEvent.modifierFlags
        if nsModifiers.contains(.shift) { modifiers.insert(.shift) }
        if nsModifiers.contains(.control) { modifiers.insert(.control) }
        if nsModifiers.contains(.option) { modifiers.insert(.option) }
        if nsModifiers.contains(.command) { modifiers.insert(.command) }
        return modifiers
    }

    private static func extractModifiers(from flags: CGEventFlags) -> KeyModifiers {
        var modifiers: KeyModifiers = []
        if flags.contains(.maskShift) { modifiers.insert(.shift) }
        if flags.contains(.maskControl) { modifiers.insert(.control) }
        if flags.contains(.maskAlternate) { modifiers.insert(.option) }
        if flags.contains(.maskCommand) { modifiers.insert(.command) }
        return modifiers
    }

    private static func handleTapDisabledEvent(
        _ type: CGEventType,
        capture: GlobalKeyboardEventCapture
    ) -> Bool {
        switch type {
        case .tapDisabledByTimeout:
            capture.handleTapDisabled(reason: .disabledByTimeout)
            return true
        case .tapDisabledByUserInput:
            capture.handleTapDisabled(reason: .disabledByUserInput)
            return true
        default:
            return false
        }
    }

    // MARK: - Start Capturing

    func startCapturing() {
        guard !isCapturing else { return }
        reEnableAttempts = 0

        guard let tap = createEventTap() else {
            handleEventTapCreationFailure()
            return
        }

        guard setupRunLoop(for: tap) else {
            handleRunLoopSetupFailure()
            return
        }

        eventTap = tap
        isCapturing = true
        AppStatus.shared.updateEventTapStatus(.operational)
    }

    // MARK: - Event Tap Creation

    private func createEventTap() -> CFMachPort? {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        selfPtr = Unmanaged.passRetained(self).toOpaque()

        let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (_, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }

                let capture = Unmanaged<GlobalKeyboardEventCapture>.fromOpaque(refcon).takeUnretainedValue()

                if GlobalKeyboardEventCapture.handleTapDisabledEvent(type, capture: capture) {
                    return Unmanaged.passRetained(event)
                }

                guard type == .keyDown else {
                    return Unmanaged.passRetained(event)
                }

                return capture.processKeyDownEvent(event)
            },
            userInfo: selfPtr
        )

        if tap == nil {
            cleanupSelfPointer()
        }

        return tap
    }

    private func processKeyDownEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

        let (chars, modifiers): (String?, KeyModifiers)
        if let nsEvent = NSEvent(cgEvent: event) {
            chars = nsEvent.characters
            modifiers = GlobalKeyboardEventCapture.extractModifiers(from: nsEvent)
        } else {
            chars = nil
            modifiers = GlobalKeyboardEventCapture.extractModifiers(from: event.flags)
        }

        let shouldConsume =
            delegate?.keyboardEventCapture(
                self, didReceiveKeyDown: keyCode, characters: chars, modifiers: modifiers
            ) ?? false

        return shouldConsume ? nil : Unmanaged.passRetained(event)
    }

    // MARK: - Run Loop Setup

    private func setupRunLoop(for tap: CFMachPort) -> Bool {
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        guard let source = runLoopSource else {
            return false
        }

        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    // MARK: - Failure Handling

    private func handleEventTapCreationFailure() {
        let reason: EventTapFailureReason = AXIsProcessTrusted() ? .systemError : .permissionDenied
        onEventTapFailed?(reason)
        AppStatus.shared.updateEventTapStatus(.failed(reason: reason.userMessage))
    }

    private func handleRunLoopSetupFailure() {
        cleanupSelfPointer()
        onEventTapFailed?(.systemError)
        AppStatus.shared.updateEventTapStatus(.failed(reason: EventTapFailureReason.systemError.userMessage))
    }

    private func cleanupSelfPointer() {
        if let ptr = selfPtr {
            Unmanaged<GlobalKeyboardEventCapture>.fromOpaque(ptr).release()
            selfPtr = nil
        }
    }

    // MARK: - Stop Capturing

    func stopCapturing() {
        guard isCapturing else { return }

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        cleanupSelfPointer()

        eventTap = nil
        runLoopSource = nil
        isCapturing = false
    }

    /// Handle event tap being disabled by system
    private func handleTapDisabled(reason: EventTapFailureReason) {
        guard let tap = eventTap else { return }

        reEnableAttempts += 1

        if reEnableAttempts <= maxReEnableAttempts {
            attemptReEnable(tap: tap, reason: reason)
        } else {
            onEventTapFailed?(reason)
            AppStatus.shared.updateEventTapStatus(.failed(reason: reason.userMessage))
        }
    }

    private func attemptReEnable(tap: CFMachPort, reason: EventTapFailureReason) {
        CGEvent.tapEnable(tap: tap, enable: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self, let tap = self.eventTap else { return }

            if CGEvent.tapIsEnabled(tap: tap) {
                self.onEventTapReEnabled?()
                AppStatus.shared.updateEventTapStatus(.operational)
            } else {
                self.onEventTapFailed?(reason)
                AppStatus.shared.updateEventTapStatus(.failed(reason: reason.userMessage))
            }
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
        return delegate?.keyboardEventCapture(
            self, didReceiveKeyDown: keyCode, characters: characters, modifiers: modifiers
        ) ?? false
    }

    /// Simulate event tap being disabled
    func simulateTapDisabled(reason: EventTapFailureReason) {
        onEventTapFailed?(reason)
    }
}
