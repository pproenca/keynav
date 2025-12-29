// Tests/KeyNavTests/HintLabelGeneratorTests.swift
import XCTest
@testable import KeyNav

final class HintLabelGeneratorTests: XCTestCase {

    func testGenerateSingleCharHints() {
        let generator = HintLabelGenerator()
        let hints = generator.generate(count: 5)

        XCTAssertEqual(hints.count, 5)
        XCTAssertEqual(hints[0], "A")
        XCTAssertEqual(hints[1], "S")
        XCTAssertEqual(hints[2], "D")
        XCTAssertEqual(hints[3], "F")
        XCTAssertEqual(hints[4], "G")
    }

    func testGenerateTwoCharHints() {
        let generator = HintLabelGenerator()
        let hints = generator.generate(count: 20)

        XCTAssertEqual(hints.count, 20)
        // First 16 are single chars
        XCTAssertEqual(hints[0], "A")
        XCTAssertEqual(hints[15], "O")
        // Then two-char combos
        XCTAssertEqual(hints[16], "AA")
        XCTAssertEqual(hints[17], "AS")
    }

    func testGenerateEmpty() {
        let generator = HintLabelGenerator()
        let hints = generator.generate(count: 0)

        XCTAssertEqual(hints.count, 0)
    }

    func testAllHintsUnique() {
        let generator = HintLabelGenerator()
        let hints = generator.generate(count: 100)
        let uniqueHints = Set(hints)

        XCTAssertEqual(hints.count, uniqueHints.count)
    }
}
