// Sources/KeyNav/Core/HotkeyTypes.swift

/// Result of hotkey registration attempt
enum HotkeyRegistrationResult {
    case success
    case failed(reason: HotkeyFailureReason)
}
