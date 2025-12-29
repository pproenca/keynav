// Sources/KeyNav/Utilities/HintLabelGenerator.swift
import Foundation

struct HintLabelGenerator {
    private let hintChars = Array("ASDFGHJKLQWERUIO")

    func generate(count: Int) -> [String] {
        guard count > 0 else { return [] }

        var hints: [String] = []

        // First pass: single chars
        for char in hintChars.prefix(min(count, hintChars.count)) {
            hints.append(String(char))
        }

        // Second pass: two-char combos if needed
        if count > hintChars.count {
            outer: for first in hintChars {
                for second in hintChars {
                    hints.append("\(first)\(second)")
                    if hints.count >= count { break outer }
                }
            }
        }

        return Array(hints.prefix(count))
    }
}
