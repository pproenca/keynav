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
        // Escape (keyCode 53)
        if keyCode == 53 {
            waitingForSecondG = false
            return .deactivate
        }

        // Ctrl+[ (keyCode 33 with control modifier) - Vim-style escape
        if keyCode == 33 && modifiers.contains(.control) {
            waitingForSecondG = false
            return .deactivate
        }

        guard let chars = characters, chars.count == 1 else {
            waitingForSecondG = false
            return .ignored
        }

        let lowercaseChars = chars.lowercased()

        // Multipliers for reversing scroll directions
        let hMultiplier: CGFloat = reverseHorizontal ? -1 : 1
        let vMultiplier: CGFloat = reverseVertical ? -1 : 1

        // Check configured keys (case insensitive for directional keys)
        if lowercaseChars == keyConfig.left.lowercased() {
            waitingForSecondG = false
            return .scroll(deltaX: smallScrollAmount * hMultiplier, deltaY: 0)
        }
        if lowercaseChars == keyConfig.down.lowercased() {
            waitingForSecondG = false
            return .scroll(deltaX: 0, deltaY: -smallScrollAmount * vMultiplier)
        }
        if lowercaseChars == keyConfig.up.lowercased() {
            waitingForSecondG = false
            return .scroll(deltaX: 0, deltaY: smallScrollAmount * vMultiplier)
        }
        if lowercaseChars == keyConfig.right.lowercased() {
            waitingForSecondG = false
            return .scroll(deltaX: -smallScrollAmount * hMultiplier, deltaY: 0)
        }
        if lowercaseChars == keyConfig.halfPageDown.lowercased() {
            waitingForSecondG = false
            return .scroll(deltaX: 0, deltaY: -pageScrollAmount * vMultiplier)
        }
        if lowercaseChars == keyConfig.halfPageUp.lowercased() {
            waitingForSecondG = false
            return .scroll(deltaX: 0, deltaY: pageScrollAmount * vMultiplier)
        }

        // Handle gg and G specially (case sensitive for toBottom)
        if lowercaseChars == keyConfig.toTop.lowercased() {
            if waitingForSecondG {
                waitingForSecondG = false
                return .scrollToTop
            } else if chars == keyConfig.toBottom || modifiers.contains(.shift) {
                // Shift+G or uppercase G
                waitingForSecondG = false
                return .scrollToBottom
            } else {
                waitingForSecondG = true
                return .waitingForG
            }
        }

        waitingForSecondG = false
        return .ignored
    }

    /// Called when waiting for second 'g' times out
    func cancelWaitingForG() {
        waitingForSecondG = false
    }
}
