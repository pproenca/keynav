// Sources/KeyNav/Core/HotkeyManager.swift
import AppKit
import Carbon
import HotKey

final class HotkeyManager {
    static let shared = HotkeyManager()

    // MARK: - Hotkey Instances

    private var hintModeHotkey: HotKey?
    private var scrollModeHotkey: HotKey?
    private var searchModeHotkey: HotKey?

    // MARK: - Configuration Storage

    private(set) var hintModeConfig: HotkeyConfiguration
    private(set) var scrollModeConfig: HotkeyConfiguration
    private(set) var searchModeConfig: HotkeyConfiguration

    // MARK: - Registration Status

    private(set) var hintModeRegistered = false
    private(set) var scrollModeRegistered = false
    private(set) var searchModeRegistered = false

    // MARK: - Callbacks

    var onHintModeActivated: (() -> Void)?
    var onScrollModeActivated: (() -> Void)?
    var onSearchModeActivated: (() -> Void)?

    /// Called when a hotkey registration fails
    var onRegistrationFailed: ((HotkeyMode, HotkeyFailureReason) -> Void)?

    // MARK: - Initialization

    private init() {
        // Default configurations
        // Cmd + Shift + Space for hint mode
        hintModeConfig = HotkeyConfiguration(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(cmdKey | shiftKey)
        )
        // Cmd + Shift + J for scroll mode
        scrollModeConfig = HotkeyConfiguration(
            keyCode: UInt32(kVK_ANSI_J),
            modifiers: UInt32(cmdKey | shiftKey)
        )
        // Cmd + Shift + / for search mode
        searchModeConfig = HotkeyConfiguration(
            keyCode: UInt32(kVK_ANSI_Slash),
            modifiers: UInt32(cmdKey | shiftKey)
        )

        loadSavedConfigurations()
    }

    // MARK: - Setup

    /// Sets up all hotkeys and returns overall success status
    @discardableResult
    func setup() -> Bool {
        let hintResult = setupHintModeHotkey()
        let scrollResult = setupScrollModeHotkey()
        let searchResult = setupSearchModeHotkey()

        // Update AppStatus with results
        updateAppStatus()

        return hintResult && scrollResult && searchResult
    }

    private func setupHintModeHotkey() -> Bool {
        hintModeHotkey = nil  // Clear existing

        let key = keyFromCode(hintModeConfig.keyCode)
        let modifiers = modifiersFromCarbon(hintModeConfig.modifiers)

        hintModeHotkey = HotKey(key: key, modifiers: modifiers)
        hintModeHotkey?.keyDownHandler = { [weak self] in
            self?.onHintModeActivated?()
        }

        // Verify registration by checking if hotkey was successfully created
        hintModeRegistered = verifyHotkeyRegistration(hintModeHotkey)

        if !hintModeRegistered {
            let reason = determineFailureReason(for: hintModeConfig)
            onRegistrationFailed?(.hint, reason)
            return false
        }

        return true
    }

    private func setupScrollModeHotkey() -> Bool {
        scrollModeHotkey = nil

        let key = keyFromCode(scrollModeConfig.keyCode)
        let modifiers = modifiersFromCarbon(scrollModeConfig.modifiers)

        scrollModeHotkey = HotKey(key: key, modifiers: modifiers)
        scrollModeHotkey?.keyDownHandler = { [weak self] in
            self?.onScrollModeActivated?()
        }

        scrollModeRegistered = verifyHotkeyRegistration(scrollModeHotkey)

        if !scrollModeRegistered {
            let reason = determineFailureReason(for: scrollModeConfig)
            onRegistrationFailed?(.scroll, reason)
            return false
        }

        return true
    }

    private func setupSearchModeHotkey() -> Bool {
        searchModeHotkey = nil

        let key = keyFromCode(searchModeConfig.keyCode)
        let modifiers = modifiersFromCarbon(searchModeConfig.modifiers)

        searchModeHotkey = HotKey(key: key, modifiers: modifiers)
        searchModeHotkey?.keyDownHandler = { [weak self] in
            self?.onSearchModeActivated?()
        }

        searchModeRegistered = verifyHotkeyRegistration(searchModeHotkey)

        if !searchModeRegistered {
            let reason = determineFailureReason(for: searchModeConfig)
            onRegistrationFailed?(.search, reason)
            return false
        }

        return true
    }

    // MARK: - Update Hotkeys

    func updateHintModeHotkey(key: Key, modifiers: NSEvent.ModifierFlags) -> HotkeyRegistrationResult {
        let carbonKeyCode = key.carbonKeyCode
        let carbonModifiers = modifiers.carbonFlags

        let newConfig = HotkeyConfiguration(keyCode: carbonKeyCode, modifiers: carbonModifiers)

        // Check for conflicts before changing
        if let conflict = checkForConflict(keyCode: carbonKeyCode, modifiers: carbonModifiers, excluding: .hint) {
            return .failed(reason: .shortcutConflict(shortcut: conflict))
        }

        hintModeConfig = newConfig
        hintModeHotkey = HotKey(key: key, modifiers: modifiers)
        hintModeHotkey?.keyDownHandler = { [weak self] in
            self?.onHintModeActivated?()
        }

        hintModeRegistered = verifyHotkeyRegistration(hintModeHotkey)

        if hintModeRegistered {
            saveConfigurations()
            updateAppStatus()
            return .success
        } else {
            let reason = determineFailureReason(for: newConfig)
            updateAppStatus()
            return .failed(reason: reason)
        }
    }

    func updateScrollModeHotkey(key: Key, modifiers: NSEvent.ModifierFlags) -> HotkeyRegistrationResult {
        let carbonKeyCode = key.carbonKeyCode
        let carbonModifiers = modifiers.carbonFlags

        let newConfig = HotkeyConfiguration(keyCode: carbonKeyCode, modifiers: carbonModifiers)

        if let conflict = checkForConflict(keyCode: carbonKeyCode, modifiers: carbonModifiers, excluding: .scroll) {
            return .failed(reason: .shortcutConflict(shortcut: conflict))
        }

        scrollModeConfig = newConfig
        scrollModeHotkey = HotKey(key: key, modifiers: modifiers)
        scrollModeHotkey?.keyDownHandler = { [weak self] in
            self?.onScrollModeActivated?()
        }

        scrollModeRegistered = verifyHotkeyRegistration(scrollModeHotkey)

        if scrollModeRegistered {
            saveConfigurations()
            updateAppStatus()
            return .success
        } else {
            let reason = determineFailureReason(for: newConfig)
            updateAppStatus()
            return .failed(reason: reason)
        }
    }

    func updateSearchModeHotkey(key: Key, modifiers: NSEvent.ModifierFlags) -> HotkeyRegistrationResult {
        let carbonKeyCode = key.carbonKeyCode
        let carbonModifiers = modifiers.carbonFlags

        let newConfig = HotkeyConfiguration(keyCode: carbonKeyCode, modifiers: carbonModifiers)

        if let conflict = checkForConflict(keyCode: carbonKeyCode, modifiers: carbonModifiers, excluding: .search) {
            return .failed(reason: .shortcutConflict(shortcut: conflict))
        }

        searchModeConfig = newConfig
        searchModeHotkey = HotKey(key: key, modifiers: modifiers)
        searchModeHotkey?.keyDownHandler = { [weak self] in
            self?.onSearchModeActivated?()
        }

        searchModeRegistered = verifyHotkeyRegistration(searchModeHotkey)

        if searchModeRegistered {
            saveConfigurations()
            updateAppStatus()
            return .success
        } else {
            let reason = determineFailureReason(for: newConfig)
            updateAppStatus()
            return .failed(reason: reason)
        }
    }

    // MARK: - Disable

    func disable() {
        hintModeHotkey = nil
        scrollModeHotkey = nil
        searchModeHotkey = nil
        hintModeRegistered = false
        scrollModeRegistered = false
        searchModeRegistered = false
        updateAppStatus()
    }

    // MARK: - Retry Registration

    func retryAllRegistrations() -> Bool {
        return setup()
    }

    // MARK: - Verification

    private func verifyHotkeyRegistration(_ hotkey: HotKey?) -> Bool {
        guard let hotkey = hotkey else { return false }

        // Check if the keyCombo is valid
        let keyCombo = hotkey.keyCombo
        if keyCombo.carbonKeyCode == 0 && keyCombo.key == nil {
            return false
        }

        // Attempt verification by trying to register with Carbon directly
        var testEventHotKey: EventHotKeyRef?
        let testID = EventHotKeyID(signature: OSType(0x4B4E_5654), id: 99999)  // "KNVT" + temp ID

        let result = RegisterEventHotKey(
            keyCombo.carbonKeyCode,
            keyCombo.carbonModifiers,
            testID,
            GetEventDispatcherTarget(),
            0,
            &testEventHotKey
        )

        if result == noErr && testEventHotKey != nil {
            // We successfully registered, unregister our test and assume success.
            UnregisterEventHotKey(testEventHotKey)
            return true
        } else if result == Int32(eventHotKeyExistsErr) {
            // Already registered - our original registration likely succeeded
            return true
        } else {
            // Registration failed - likely permission issue or system error
            return false
        }
    }

    private func determineFailureReason(for config: HotkeyConfiguration) -> HotkeyFailureReason {
        // Check if accessibility is enabled
        if !AXIsProcessTrusted() {
            return .permissionDenied
        }

        // Try to register and check the specific error
        var testEventHotKey: EventHotKeyRef?
        let testID = EventHotKeyID(signature: OSType(0x5445_5354), id: 1)  // "TEST"

        let result = RegisterEventHotKey(
            config.keyCode,
            config.modifiers,
            testID,
            GetEventDispatcherTarget(),
            0,
            &testEventHotKey
        )

        if testEventHotKey != nil {
            UnregisterEventHotKey(testEventHotKey)
        }

        switch result {
        case noErr:
            return .unknown
        case Int32(eventHotKeyExistsErr):
            return .shortcutConflict(shortcut: config.displayString)
        default:
            return .systemError(code: Int(result))
        }
    }

    // MARK: - Conflict Detection

    private func checkForConflict(keyCode: UInt32, modifiers: UInt32, excluding mode: HotkeyMode) -> String? {
        let configs: [(HotkeyMode, HotkeyConfiguration)] = [
            (.hint, hintModeConfig),
            (.scroll, scrollModeConfig),
            (.search, searchModeConfig),
        ]

        for (configMode, config) in configs {
            if configMode == mode { continue }
            if config.keyCode == keyCode && config.modifiers == modifiers {
                let modeName: String
                switch configMode {
                case .hint: modeName = "Hint Mode"
                case .scroll: modeName = "Scroll Mode"
                case .search: modeName = "Search Mode"
                }
                return "\(modeName) (\(config.displayString))"
            }
        }

        return nil
    }

    // MARK: - AppStatus Integration

    private func updateAppStatus() {
        if hintModeRegistered {
            AppStatus.shared.updateHintModeHotkeyStatus(.operational)
        } else {
            let reason = determineFailureReason(for: hintModeConfig)
            AppStatus.shared.updateHintModeHotkeyStatus(.failed(reason: reason.userMessage))
        }

        if scrollModeRegistered {
            AppStatus.shared.updateScrollModeHotkeyStatus(.operational)
        } else {
            let reason = determineFailureReason(for: scrollModeConfig)
            AppStatus.shared.updateScrollModeHotkeyStatus(.failed(reason: reason.userMessage))
        }

        if searchModeRegistered {
            AppStatus.shared.updateSearchModeHotkeyStatus(.operational)
        } else {
            let reason = determineFailureReason(for: searchModeConfig)
            AppStatus.shared.updateSearchModeHotkeyStatus(.failed(reason: reason.userMessage))
        }
    }

    // MARK: - Persistence

    private func loadSavedConfigurations() {
        guard let configs = HotkeyStorage.loadConfigurations() else { return }
        if let hint = configs["hint"] { hintModeConfig = hint }
        if let scroll = configs["scroll"] { scrollModeConfig = scroll }
        if let search = configs["search"] { searchModeConfig = search }
    }

    private func saveConfigurations() {
        HotkeyStorage.saveConfigurations(hint: hintModeConfig, scroll: scrollModeConfig, search: searchModeConfig)
    }

    // MARK: - Key Conversion Helpers

    private static let keyCodeToKeyMap: [Int: Key] = [
        kVK_Space: .space, kVK_Return: .return, kVK_Tab: .tab, kVK_Delete: .delete, kVK_Escape: .escape,
        kVK_ANSI_A: .a, kVK_ANSI_S: .s, kVK_ANSI_D: .d, kVK_ANSI_F: .f, kVK_ANSI_H: .h, kVK_ANSI_G: .g,
        kVK_ANSI_Z: .z, kVK_ANSI_X: .x, kVK_ANSI_C: .c, kVK_ANSI_V: .v, kVK_ANSI_B: .b, kVK_ANSI_Q: .q,
        kVK_ANSI_W: .w, kVK_ANSI_E: .e, kVK_ANSI_R: .r, kVK_ANSI_Y: .y, kVK_ANSI_T: .t, kVK_ANSI_O: .o,
        kVK_ANSI_U: .u, kVK_ANSI_I: .i, kVK_ANSI_P: .p, kVK_ANSI_L: .l, kVK_ANSI_J: .j, kVK_ANSI_K: .k,
        kVK_ANSI_N: .n, kVK_ANSI_M: .m, kVK_ANSI_Slash: .slash, kVK_ANSI_Semicolon: .semicolon,
        kVK_ANSI_Quote: .quote, kVK_ANSI_Comma: .comma, kVK_ANSI_Period: .period, kVK_ANSI_Backslash: .backslash,
        kVK_ANSI_LeftBracket: .leftBracket, kVK_ANSI_RightBracket: .rightBracket,
        kVK_ANSI_Minus: .minus, kVK_ANSI_Equal: .equal,
        kVK_ANSI_0: .zero, kVK_ANSI_1: .one, kVK_ANSI_2: .two, kVK_ANSI_3: .three, kVK_ANSI_4: .four,
        kVK_ANSI_5: .five, kVK_ANSI_6: .six, kVK_ANSI_7: .seven, kVK_ANSI_8: .eight, kVK_ANSI_9: .nine,
    ]

    private func keyFromCode(_ keyCode: UInt32) -> Key {
        return Self.keyCodeToKeyMap[Int(keyCode)] ?? .space
    }

    private func modifiersFromCarbon(_ carbonModifiers: UInt32) -> NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if carbonModifiers & UInt32(cmdKey) != 0 { flags.insert(.command) }
        if carbonModifiers & UInt32(shiftKey) != 0 { flags.insert(.shift) }
        if carbonModifiers & UInt32(optionKey) != 0 { flags.insert(.option) }
        if carbonModifiers & UInt32(controlKey) != 0 { flags.insert(.control) }
        return flags
    }
}

// MARK: - Key Extension

extension Key {
    var carbonKeyCode: UInt32 {
        switch self {
        case .space: return UInt32(kVK_Space)
        case .return: return UInt32(kVK_Return)
        case .tab: return UInt32(kVK_Tab)
        case .delete: return UInt32(kVK_Delete)
        case .escape: return UInt32(kVK_Escape)
        case .a: return UInt32(kVK_ANSI_A)
        case .s: return UInt32(kVK_ANSI_S)
        case .d: return UInt32(kVK_ANSI_D)
        case .f: return UInt32(kVK_ANSI_F)
        case .h: return UInt32(kVK_ANSI_H)
        case .g: return UInt32(kVK_ANSI_G)
        case .z: return UInt32(kVK_ANSI_Z)
        case .x: return UInt32(kVK_ANSI_X)
        case .c: return UInt32(kVK_ANSI_C)
        case .v: return UInt32(kVK_ANSI_V)
        case .b: return UInt32(kVK_ANSI_B)
        case .q: return UInt32(kVK_ANSI_Q)
        case .w: return UInt32(kVK_ANSI_W)
        case .e: return UInt32(kVK_ANSI_E)
        case .r: return UInt32(kVK_ANSI_R)
        case .y: return UInt32(kVK_ANSI_Y)
        case .t: return UInt32(kVK_ANSI_T)
        case .o: return UInt32(kVK_ANSI_O)
        case .u: return UInt32(kVK_ANSI_U)
        case .i: return UInt32(kVK_ANSI_I)
        case .p: return UInt32(kVK_ANSI_P)
        case .l: return UInt32(kVK_ANSI_L)
        case .j: return UInt32(kVK_ANSI_J)
        case .k: return UInt32(kVK_ANSI_K)
        case .n: return UInt32(kVK_ANSI_N)
        case .m: return UInt32(kVK_ANSI_M)
        case .slash: return UInt32(kVK_ANSI_Slash)
        case .semicolon: return UInt32(kVK_ANSI_Semicolon)
        case .quote: return UInt32(kVK_ANSI_Quote)
        case .comma: return UInt32(kVK_ANSI_Comma)
        case .period: return UInt32(kVK_ANSI_Period)
        case .backslash: return UInt32(kVK_ANSI_Backslash)
        case .leftBracket: return UInt32(kVK_ANSI_LeftBracket)
        case .rightBracket: return UInt32(kVK_ANSI_RightBracket)
        case .minus: return UInt32(kVK_ANSI_Minus)
        case .equal: return UInt32(kVK_ANSI_Equal)
        case .zero: return UInt32(kVK_ANSI_0)
        case .one: return UInt32(kVK_ANSI_1)
        case .two: return UInt32(kVK_ANSI_2)
        case .three: return UInt32(kVK_ANSI_3)
        case .four: return UInt32(kVK_ANSI_4)
        case .five: return UInt32(kVK_ANSI_5)
        case .six: return UInt32(kVK_ANSI_6)
        case .seven: return UInt32(kVK_ANSI_7)
        case .eight: return UInt32(kVK_ANSI_8)
        case .nine: return UInt32(kVK_ANSI_9)
        default: return UInt32(kVK_Space)
        }
    }
}

// MARK: - NSEvent.ModifierFlags Extension

extension NSEvent.ModifierFlags {
    var carbonFlags: UInt32 {
        var flags: UInt32 = 0
        if contains(.command) { flags |= UInt32(cmdKey) }
        if contains(.shift) { flags |= UInt32(shiftKey) }
        if contains(.option) { flags |= UInt32(optionKey) }
        if contains(.control) { flags |= UInt32(controlKey) }
        return flags
    }
}
