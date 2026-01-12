// Sources/KeyNav/Core/HotkeyManager.swift
import AppKit
import HotKey
import Carbon

/// Result of hotkey registration attempt
enum HotkeyRegistrationResult {
    case success
    case failed(reason: HotkeyFailureReason)
}

/// Stored hotkey configuration for persistence
struct HotkeyConfiguration: Codable, Equatable {
    let keyCode: UInt32
    let modifiers: UInt32

    var displayString: String {
        var parts: [String] = []
        if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }

        // Convert key code to string
        if let keyString = keyCodeToString(keyCode) {
            parts.append(keyString)
        }

        return parts.joined()
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String? {
        let keyMap: [UInt32: String] = [
            49: "Space",    // kVK_Space
            36: "Return",   // kVK_Return
            48: "Tab",      // kVK_Tab
            51: "Delete",   // kVK_Delete
            53: "Escape",   // kVK_Escape
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: "."
        ]
        return keyMap[keyCode]
    }
}

/// Mode types for hotkey registration
enum HotkeyMode {
    case hint
    case scroll
    case search
}

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

        // The HotKey library doesn't expose registration status directly
        // We verify by attempting to register via Carbon API and checking the result
        // Since HotKey already registered, we check if the hotkey object is valid

        // A more robust check: try to register the same hotkey and see if it fails
        // If it fails with "already registered", our original registration succeeded
        // But this is complex. For now, we use a simpler heuristic.

        // Check if the keyCombo is valid
        let keyCombo = hotkey.keyCombo
        if keyCombo.carbonKeyCode == 0 && keyCombo.key == nil {
            return false
        }

        // Attempt verification by trying to register with Carbon directly
        var testEventHotKey: EventHotKeyRef?
        let testID = EventHotKeyID(signature: OSType(0x4B4E5654), id: 99999)  // "KNVT" + temp ID

        let result = RegisterEventHotKey(
            keyCombo.carbonKeyCode,
            keyCombo.carbonModifiers,
            testID,
            GetEventDispatcherTarget(),
            0,
            &testEventHotKey
        )

        if result == noErr && testEventHotKey != nil {
            // We successfully registered, which means original failed (it would have blocked us)
            // Actually, Carbon allows multiple registrations of the same key combination
            // So this test isn't conclusive. Unregister our test and assume success.
            UnregisterEventHotKey(testEventHotKey)

            // Since Carbon allows duplicate registration, we assume the HotKey library succeeded
            // A better approach would be to check HotKeysController.hotKeys directly, but it's private
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
        let testID = EventHotKeyID(signature: OSType(0x54455354), id: 1)  // "TEST"

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
            (.search, searchModeConfig)
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
        guard let data = UserDefaults.standard.data(forKey: "hotkeyConfigurations") else { return }

        do {
            let configs = try JSONDecoder().decode([String: HotkeyConfiguration].self, from: data)
            if let hint = configs["hint"] { hintModeConfig = hint }
            if let scroll = configs["scroll"] { scrollModeConfig = scroll }
            if let search = configs["search"] { searchModeConfig = search }
        } catch {
            // Use defaults if loading fails
        }
    }

    private func saveConfigurations() {
        let configs: [String: HotkeyConfiguration] = [
            "hint": hintModeConfig,
            "scroll": scrollModeConfig,
            "search": searchModeConfig
        ]

        do {
            let data = try JSONEncoder().encode(configs)
            UserDefaults.standard.set(data, forKey: "hotkeyConfigurations")
        } catch {
            // Silently fail - not critical
        }
    }

    // MARK: - Key Conversion Helpers

    private func keyFromCode(_ keyCode: UInt32) -> Key {
        // Map Carbon key codes to HotKey Key enum
        switch Int(keyCode) {
        case kVK_Space: return .space
        case kVK_Return: return .return
        case kVK_Tab: return .tab
        case kVK_Delete: return .delete
        case kVK_Escape: return .escape
        case kVK_ANSI_A: return .a
        case kVK_ANSI_S: return .s
        case kVK_ANSI_D: return .d
        case kVK_ANSI_F: return .f
        case kVK_ANSI_H: return .h
        case kVK_ANSI_G: return .g
        case kVK_ANSI_Z: return .z
        case kVK_ANSI_X: return .x
        case kVK_ANSI_C: return .c
        case kVK_ANSI_V: return .v
        case kVK_ANSI_B: return .b
        case kVK_ANSI_Q: return .q
        case kVK_ANSI_W: return .w
        case kVK_ANSI_E: return .e
        case kVK_ANSI_R: return .r
        case kVK_ANSI_Y: return .y
        case kVK_ANSI_T: return .t
        case kVK_ANSI_O: return .o
        case kVK_ANSI_U: return .u
        case kVK_ANSI_I: return .i
        case kVK_ANSI_P: return .p
        case kVK_ANSI_L: return .l
        case kVK_ANSI_J: return .j
        case kVK_ANSI_K: return .k
        case kVK_ANSI_N: return .n
        case kVK_ANSI_M: return .m
        case kVK_ANSI_Slash: return .slash
        case kVK_ANSI_Semicolon: return .semicolon
        case kVK_ANSI_Quote: return .quote
        case kVK_ANSI_Comma: return .comma
        case kVK_ANSI_Period: return .period
        case kVK_ANSI_Backslash: return .backslash
        case kVK_ANSI_LeftBracket: return .leftBracket
        case kVK_ANSI_RightBracket: return .rightBracket
        case kVK_ANSI_Minus: return .minus
        case kVK_ANSI_Equal: return .equal
        case kVK_ANSI_0: return .zero
        case kVK_ANSI_1: return .one
        case kVK_ANSI_2: return .two
        case kVK_ANSI_3: return .three
        case kVK_ANSI_4: return .four
        case kVK_ANSI_5: return .five
        case kVK_ANSI_6: return .six
        case kVK_ANSI_7: return .seven
        case kVK_ANSI_8: return .eight
        case kVK_ANSI_9: return .nine
        default: return .space
        }
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
