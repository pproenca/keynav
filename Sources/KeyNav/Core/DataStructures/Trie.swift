// Sources/KeyNav/Core/DataStructures/Trie.swift
import Foundation

/// A node in the Trie data structure
private class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isEndOfWord: Bool = false
}

/// Trie data structure for efficient prefix matching
/// Used for hint label matching in HintMode
final class Trie {
    private let root = TrieNode()

    /// Inserts a word into the trie
    func insert(_ word: String) {
        var current = root
        for char in word {
            if current.children[char] == nil {
                current.children[char] = TrieNode()
            }
            current = current.children[char]!
        }
        current.isEndOfWord = true
    }

    /// Returns true if the word exists in the trie
    func contains(_ word: String) -> Bool {
        guard let node = findNode(for: word) else { return false }
        return node.isEndOfWord
    }

    /// Returns true if the given string is a prefix of any word in the trie
    func isPrefix(_ prefix: String) -> Bool {
        return findNode(for: prefix) != nil
    }

    /// Returns true if there exists a word in the trie that is a proper prefix of the given string
    /// and that word terminates (is a complete word)
    /// Example: if "a" is inserted and we check "abc", returns true because "a" is a terminating prefix
    func doesTerminatingPrefixExist(_ word: String) -> Bool {
        var current = root
        for (index, char) in word.enumerated() {
            // Check if current node marks end of a word (before reaching end of input)
            if current.isEndOfWord && index < word.count {
                return true
            }
            guard let next = current.children[char] else {
                return false
            }
            current = next
        }
        // Don't count the word itself as its own terminating prefix
        return false
    }

    /// Returns all words stored in the trie
    func getAllWords() -> [String] {
        var words: [String] = []
        collectWords(from: root, prefix: "", into: &words)
        return words
    }

    /// Returns all words that start with the given prefix
    func getWordsWithPrefix(_ prefix: String) -> [String] {
        guard let node = findNode(for: prefix) else { return [] }
        var words: [String] = []
        collectWords(from: node, prefix: prefix, into: &words)
        return words
    }

    // MARK: - Private Helpers

    private func findNode(for prefix: String) -> TrieNode? {
        var current = root
        for char in prefix {
            guard let next = current.children[char] else {
                return nil
            }
            current = next
        }
        return current
    }

    private func collectWords(from node: TrieNode, prefix: String, into words: inout [String]) {
        if node.isEndOfWord {
            words.append(prefix)
        }
        for (char, child) in node.children {
            collectWords(from: child, prefix: prefix + String(char), into: &words)
        }
    }
}
