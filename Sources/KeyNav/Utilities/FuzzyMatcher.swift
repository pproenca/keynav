// Sources/KeyNav/Utilities/FuzzyMatcher.swift
import Foundation

struct FuzzyMatcher {

    func matches(query: String, in text: String) -> Bool {
        guard !query.isEmpty else { return true }
        return text.localizedCaseInsensitiveContains(query)
    }

    func matchRange(query: String, in text: String) -> Range<String.Index>? {
        guard !query.isEmpty else { return nil }
        return text.range(of: query, options: .caseInsensitive)
    }

    func filter(elements: [ActionableElement], query: String) -> [ActionableElement] {
        guard !query.isEmpty else { return elements }

        return elements.filter { matches(query: query, in: $0.label) }
    }

    func score(query: String, in text: String) -> Int {
        guard matches(query: query, in: text) else { return 0 }

        let lowercaseText = text.lowercased()
        let lowercaseQuery = query.lowercased()

        // Exact match gets highest score
        if lowercaseText == lowercaseQuery { return 100 }

        // Starts with query gets high score
        if lowercaseText.hasPrefix(lowercaseQuery) { return 80 }

        // Contains query gets medium score
        return 50
    }

    func filterAndSort(elements: [ActionableElement], query: String) -> [ActionableElement] {
        guard !query.isEmpty else { return elements }

        return
            elements
            .map { ($0, score(query: query, in: $0.label)) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}
