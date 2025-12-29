// Sources/KeyNav/Core/Modes/HintModeLogic.swift
import Foundation

/// Pure logic for HintMode, separated from UI for testability
final class HintModeLogic {
    private let hintGenerator = HintLabelGenerator()
    private let fuzzyMatcher = FuzzyMatcher()

    private(set) var elements: [ActionableElement] = []
    private(set) var filteredElements: [ActionableElement] = []
    private(set) var hintLabels: [String] = []
    private(set) var currentQuery = ""
    private(set) var typedHintChars = ""

    enum KeyResult {
        case ignored
        case handled
        case deactivate
        case selectElement(ActionableElement)
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
    }

    func handleKeyCode(_ keyCode: UInt16, characters: String?) -> KeyResult {
        // Escape (keyCode 53)
        if keyCode == 53 {
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
                return .selectElement(element)
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

    func handleSearchTextChange(_ text: String) -> KeyResult? {
        currentQuery = text.lowercased()
        typedHintChars = ""
        updateFilteredElements()
        regenerateHints()

        // Auto-select if single match
        if filteredElements.count == 1 && !currentQuery.isEmpty {
            return .selectElement(filteredElements[0])
        }
        return nil
    }

    func handleEnter() -> KeyResult? {
        if let first = filteredElements.first {
            return .selectElement(first)
        }
        return nil
    }

    private func updateFilteredElements() {
        filteredElements = fuzzyMatcher.filterAndSort(elements: elements, query: currentQuery)
        typedHintChars = ""
    }

    private func regenerateHints() {
        hintLabels = hintGenerator.generate(count: filteredElements.count)
    }

    private func isHintChar(_ char: Character) -> Bool {
        "ASDFGHJKLQWERUIO".contains(char)
    }
}
