// Tests/KeyNavTests/HintCharacterPrefsTests.swift
import XCTest
@testable import KeyNav

final class HintCharacterPrefsTests: XCTestCase {

    // MARK: - Default Configuration

    func testDefaultHintCharacters() {
        let prefs = HintCharacterPrefs()

        XCTAssertEqual(prefs.characters, "sadfjklewcmpgh")
    }

    func testDefaultCharacterCount() {
        let prefs = HintCharacterPrefs()

        XCTAssertEqual(prefs.characters.count, 14)
    }

    // MARK: - Custom Characters

    func testCustomHintCharacters() {
        let prefs = HintCharacterPrefs(characters: "abcdef")

        XCTAssertEqual(prefs.characters, "abcdef")
    }

    // MARK: - Validation

    func testMinimumCharacterCount() {
        let valid = HintCharacterPrefs.isValid("abcdef")
        let invalid = HintCharacterPrefs.isValid("abc")

        XCTAssertTrue(valid)
        XCTAssertFalse(invalid)
    }

    func testUniqueCharactersRequired() {
        let valid = HintCharacterPrefs.isValid("abcdef")
        let invalid = HintCharacterPrefs.isValid("aabcde")  // Duplicate 'a'

        XCTAssertTrue(valid)
        XCTAssertFalse(invalid)
    }

    func testValidationRejectsDuplicates() {
        XCTAssertFalse(HintCharacterPrefs.isValid("abcdea"))  // 'a' duplicated
        XCTAssertFalse(HintCharacterPrefs.isValid("aabbcc"))  // Multiple duplicates
    }

    func testValidationAcceptsLongStrings() {
        let longValid = "abcdefghijklmnopqrstuvwxyz"
        XCTAssertTrue(HintCharacterPrefs.isValid(longValid))
    }

    // MARK: - Character Array

    func testCharacterArray() {
        let prefs = HintCharacterPrefs(characters: "abcdef")

        XCTAssertEqual(prefs.characterArray, ["a", "b", "c", "d", "e", "f"])
    }
}
