// Sources/KeyNav/Core/Modes/ScrollModeLogic.swift
import Foundation

/// Pure logic for ScrollMode, separated from UI for testability
final class ScrollModeLogic {
    private(set) var waitingForSecondG = false

    private let smallScrollAmount: CGFloat
    private let pageScrollAmount: CGFloat
    private let keyConfig: ScrollKeyConfig
    private let reverseHorizontal: Bool
    private let reverseVertical: Bool

    init(
        smallScrollAmount: CGFloat = 50,
        pageScrollAmount: CGFloat = 300,
        keyConfig: ScrollKeyConfig = ScrollKeyConfig(),
        reverseHorizontal: Bool = false,
        reverseVertical: Bool = false
    ) {
        self.smallScrollAmount = smallScrollAmount
        self.pageScrollAmount = pageScrollAmount
        self.keyConfig = keyConfig
        self.reverseHorizontal = reverseHorizontal
        self.reverseVertical = reverseVertical
    }

    enum KeyResult: Equatable {
        case ignored
        case deactivate
        case scroll(deltaX: CGFloat, deltaY: CGFloat)
        case scrollToTop
        case scrollToBottom
        case waitingForG
    }

    func reset() {
        waitingForSecondG = false
    }

    func handleKeyCode(_ keyCode: UInt16, characters: String?, modifiers: KeyModifiers = []) -> KeyResult {
        // Check for deactivation keys
        if isDeactivationKey(keyCode: keyCode, modifiers: modifiers) {
            waitingForSecondG = false
            return .deactivate
        }

        guard let chars = characters, chars.count == 1 else {
            waitingForSecondG = false
            return .ignored
        }

        let lowercaseChars = chars.lowercased()

        // Check scroll direction keys
        if let scrollResult = scrollResultFor(key: lowercaseChars) {
            waitingForSecondG = false
            return scrollResult
        }

        // Handle gg and G specially (case sensitive for toBottom)
        if lowercaseChars == keyConfig.toTop.lowercased() {
            return handleTopBottomKey(chars: chars, modifiers: modifiers)
        }

        waitingForSecondG = false
        return .ignored
    }

    private func isDeactivationKey(keyCode: UInt16, modifiers: KeyModifiers) -> Bool {
        // Escape (keyCode 53) or Ctrl+[ (keyCode 33 with control modifier)
        return keyCode == 53 || (keyCode == 33 && modifiers.contains(.control))
    }

    private func scrollResultFor(key: String) -> KeyResult? {
        let hMult: CGFloat = reverseHorizontal ? -1 : 1
        let vMult: CGFloat = reverseVertical ? -1 : 1

        let mappings: [String: KeyResult] = [
            keyConfig.left.lowercased(): .scroll(deltaX: smallScrollAmount * hMult, deltaY: 0),
            keyConfig.down.lowercased(): .scroll(deltaX: 0, deltaY: -smallScrollAmount * vMult),
            keyConfig.up.lowercased(): .scroll(deltaX: 0, deltaY: smallScrollAmount * vMult),
            keyConfig.right.lowercased(): .scroll(deltaX: -smallScrollAmount * hMult, deltaY: 0),
            keyConfig.halfPageDown.lowercased(): .scroll(deltaX: 0, deltaY: -pageScrollAmount * vMult),
            keyConfig.halfPageUp.lowercased(): .scroll(deltaX: 0, deltaY: pageScrollAmount * vMult),
        ]
        return mappings[key]
    }

    private func handleTopBottomKey(chars: String, modifiers: KeyModifiers) -> KeyResult {
        if waitingForSecondG {
            waitingForSecondG = false
            return .scrollToTop
        } else if chars == keyConfig.toBottom || modifiers.contains(.shift) {
            waitingForSecondG = false
            return .scrollToBottom
        } else {
            waitingForSecondG = true
            return .waitingForG
        }
    }

    /// Called when waiting for second 'g' times out
    func cancelWaitingForG() {
        waitingForSecondG = false
    }
}
