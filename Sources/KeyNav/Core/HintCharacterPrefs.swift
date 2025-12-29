// Sources/KeyNav/Core/HintCharacterPrefs.swift
import Foundation

/// User preferences for hint characters
struct HintCharacterPrefs: Codable, Equatable {
    /// Characters used to generate hints
    /// Default matches Vimac: "sadfjklewcmpgh"
    let characters: String

    /// Minimum number of characters required
    static let minimumCharacterCount = 6

    init(characters: String = "sadfjklewcmpgh") {
        self.characters = characters
    }

    /// Array of individual characters
    var characterArray: [String] {
        return characters.map { String($0) }
    }

    /// Validate a character string for use as hints
    /// - Parameter characters: The string to validate
    /// - Returns: True if valid (minimum 6 unique characters)
    static func isValid(_ characters: String) -> Bool {
        guard characters.count >= minimumCharacterCount else {
            return false
        }

        // Check for uniqueness
        let characterSet = Set(characters)
        return characterSet.count == characters.count
    }
}
