// Sources/KeyNav/Core/Modes/HintModeLogic.swift
import Foundation

/// Type of click action to perform
enum ClickType: Equatable {
    case leftClick
    case rightClick
    case doubleClick
    case moveOnly
}

/// Keyboard modifiers for determining click type
struct KeyModifiers: OptionSet {
    let rawValue: UInt

    static let shift = KeyModifiers(rawValue: 1 << 0)
    static let control = KeyModifiers(rawValue: 1 << 1)
    static let option = KeyModifiers(rawValue: 1 << 2)
    static let command = KeyModifiers(rawValue: 1 << 3)
}

/// Pure logic for HintMode, separated from UI for testability
final class HintModeLogic {
    private let hintGenerator = HintLabelGenerator()
    private let fuzzyMatcher = FuzzyMatcher()

    private(set) var elements: [ActionableElement] = []
    private(set) var filteredElements: [ActionableElement] = []
    private(set) var hintLabels: [String] = []
    private(set) var currentQuery = ""
    private(set) var typedHintChars = ""
    private(set) var selectedHintIndex: Int = 0

    enum KeyResult: Equatable {
        case ignored
        case handled
        case deactivate
        case selectElement(ActionableElement, ClickType)

        static func == (lhs: KeyResult, rhs: KeyResult) -> Bool {
            switch (lhs, rhs) {
            case (.ignored, .ignored), (.handled, .handled), (.deactivate, .deactivate):
                return true
            case let (.selectElement(e1, c1), .selectElement(e2, c2)):
                return e1 == e2 && c1 == c2
            default:
                return false
            }
        }
    }

    func setElements(_ elements: [ActionableElement]) {
        self.elements = elements
        self.filteredElements = elements
        regenerateHints()
    }

    func reset() {
        elements = []
        filteredElements = []
        hintLabels = []
        currentQuery = ""
        typedHintChars = ""
        selectedHintIndex = 0
    }

    func handleKeyCode(_ keyCode: UInt16, characters: String?, modifiers: KeyModifiers = []) -> KeyResult {
        // Escape (keyCode 53)
        if keyCode == 53 {
            return .deactivate
        }

        // Ctrl+[ (keyCode 33 with control modifier) - Vim-style escape
        if keyCode == 33 && modifiers.contains(.control) {
            return .deactivate
        }

        // Backspace (keyCode 51)
        if keyCode == 51 {
            if !typedHintChars.isEmpty {
                typedHintChars.removeLast()
            } else if !currentQuery.isEmpty {
                currentQuery.removeLast()
                updateFilteredElements()
            }
            regenerateHints()
            return .handled
        }

        // Regular character
        guard let chars = characters?.uppercased(), chars.count == 1, let char = chars.first else {
            return .ignored
        }

        // Check if this could be part of a hint
        if isHintChar(char) && !filteredElements.isEmpty {
            typedHintChars.append(char)

            // Check for exact hint match
            if let index = hintLabels.firstIndex(of: typedHintChars), index < filteredElements.count {
                let element = filteredElements[index]
                let clickType = determineClickType(from: modifiers)
                return .selectElement(element, clickType)
            }

            // Check if this could still match a multi-char hint
            let possibleMatches = hintLabels.filter { $0.hasPrefix(typedHintChars) }
            if possibleMatches.isEmpty {
                // Not a hint prefix, treat as search query
                typedHintChars = ""
                currentQuery.append(Character(chars.lowercased()))
                updateFilteredElements()
            }

            regenerateHints()
            return .handled
        } else {
            // Non-hint character, treat as search query
            currentQuery.append(Character(chars.lowercased()))
            typedHintChars = ""
            updateFilteredElements()
            regenerateHints()
            return .handled
        }
    }

    /// Determine click type based on modifier keys
    /// Priority: Shift (right-click) > Command (double-click) > Option (move only) > default (left-click)
    private func determineClickType(from modifiers: KeyModifiers) -> ClickType {
        if modifiers.contains(.shift) {
            return .rightClick
        } else if modifiers.contains(.command) {
            return .doubleClick
        } else if modifiers.contains(.option) {
            return .moveOnly
        } else {
            return .leftClick
        }
    }

    func handleSearchTextChange(_ text: String, modifiers: KeyModifiers = []) -> KeyResult? {
        currentQuery = text.lowercased()
        typedHintChars = ""
        updateFilteredElements()
        regenerateHints()

        // Auto-select if single match
        if filteredElements.count == 1 && !currentQuery.isEmpty {
            let clickType = determineClickType(from: modifiers)
            return .selectElement(filteredElements[0], clickType)
        }
        return nil
    }

    func handleEnter(modifiers: KeyModifiers = []) -> KeyResult? {
        guard !filteredElements.isEmpty else { return nil }
        let index = min(selectedHintIndex, filteredElements.count - 1)
        let element = filteredElements[index]
        let clickType = determineClickType(from: modifiers)
        return .selectElement(element, clickType)
    }

    /// Cycles through hints at the same position (Space bar functionality)
    /// Returns .handled if rotation occurred, .ignored otherwise
    func handleSpace() -> KeyResult {
        // Only rotate if we have typed some hint characters
        guard !typedHintChars.isEmpty, !filteredElements.isEmpty else {
            return .ignored
        }

        // Cycle to next element
        selectedHintIndex = (selectedHintIndex + 1) % filteredElements.count
        return .handled
    }

    private func updateFilteredElements() {
        filteredElements = fuzzyMatcher.filterAndSort(elements: elements, query: currentQuery)
        typedHintChars = ""
        selectedHintIndex = 0
    }

    private func regenerateHints() {
        hintLabels = hintGenerator.generate(count: filteredElements.count)
    }

    private func isHintChar(_ char: Character) -> Bool {
        "ASDFGHJKLQWERUIO".contains(char)
    }
}
