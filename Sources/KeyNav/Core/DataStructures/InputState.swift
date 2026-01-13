// Sources/KeyNav/Core/DataStructures/InputState.swift
import Foundation

/// State machine for handling keyboard input sequences
/// Used in HintMode for efficient multi-character hint matching
final class InputState {

    /// Possible states of the input state machine
    enum State: Equatable {
        case initialized  // No sequences registered yet
        case wordsAdded  // Sequences registered, ready to receive input
        case advancable  // Valid prefix entered, can continue or match
        case match  // Complete match found
        case deadend  // Invalid input, no possible match
    }

    private(set) var state: State = .initialized
    private(set) var currentInput: String = ""
    private(set) var matchedWord: String?

    private let trie = Trie()
    private var registeredSequences: Set<String> = []

    /// Registers a key sequence for matching
    /// Returns false if the sequence conflicts with existing registrations
    @discardableResult
    func addKeySequence(_ sequence: String) -> Bool {
        // Check for duplicate
        if registeredSequences.contains(sequence) {
            return false
        }

        // Check if this sequence is a prefix of any existing sequence
        // (would be ambiguous when to match)
        if !trie.getWordsWithPrefix(sequence).isEmpty {
            return false
        }

        // Check if any existing sequence is a prefix of this new one
        // (the existing sequence would match before we could complete this one)
        if trie.doesTerminatingPrefixExist(sequence) {
            return false
        }

        registeredSequences.insert(sequence)
        trie.insert(sequence)
        state = .wordsAdded
        return true
    }

    /// Advances the state machine with a new character
    func advance(with character: Character) {
        let newInput = currentInput + String(character)

        // Check if this forms a complete match
        if trie.contains(newInput) {
            currentInput = newInput
            matchedWord = newInput
            state = .match
            return
        }

        // Check if this is still a valid prefix
        if trie.isPrefix(newInput) {
            currentInput = newInput
            state = .advancable
            return
        }

        // No match possible
        state = .deadend
    }

    /// Advances the state machine with a string of characters
    func advance(with string: String) {
        for char in string {
            advance(with: char)
            if state == .deadend || state == .match {
                break
            }
        }
    }

    /// Resets the input state while preserving registered sequences
    func reset() {
        currentInput = ""
        matchedWord = nil
        state = registeredSequences.isEmpty ? .initialized : .wordsAdded
    }

    /// Completely clears the state machine including registered sequences
    func clear() {
        reset()
        registeredSequences.removeAll()
        state = .initialized
    }
}
