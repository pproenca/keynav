// Tests/KeyNavTests/CJKVKeyboardTests.swift
import XCTest
@testable import KeyNav

final class CJKVKeyboardTests: XCTestCase {

    // MARK: - CJKV Language Detection

    func testKoreanDetection() {
        let detector = CJKVKeyboardDetector()

        XCTAssertTrue(detector.isCJKV(languageCode: "ko"))
        XCTAssertTrue(detector.isCJKV(languageCode: "ko-KR"))
    }

    func testJapaneseDetection() {
        let detector = CJKVKeyboardDetector()

        XCTAssertTrue(detector.isCJKV(languageCode: "ja"))
        XCTAssertTrue(detector.isCJKV(languageCode: "ja-JP"))
    }

    func testVietnameseDetection() {
        let detector = CJKVKeyboardDetector()

        XCTAssertTrue(detector.isCJKV(languageCode: "vi"))
        XCTAssertTrue(detector.isCJKV(languageCode: "vi-VN"))
    }

    func testChineseDetection() {
        let detector = CJKVKeyboardDetector()

        XCTAssertTrue(detector.isCJKV(languageCode: "zh"))
        XCTAssertTrue(detector.isCJKV(languageCode: "zh-Hans"))
        XCTAssertTrue(detector.isCJKV(languageCode: "zh-Hant"))
        XCTAssertTrue(detector.isCJKV(languageCode: "zh-TW"))
        XCTAssertTrue(detector.isCJKV(languageCode: "zh-CN"))
    }

    // MARK: - Non-CJKV Detection

    func testEnglishNotCJKV() {
        let detector = CJKVKeyboardDetector()

        XCTAssertFalse(detector.isCJKV(languageCode: "en"))
        XCTAssertFalse(detector.isCJKV(languageCode: "en-US"))
    }

    func testSpanishNotCJKV() {
        let detector = CJKVKeyboardDetector()

        XCTAssertFalse(detector.isCJKV(languageCode: "es"))
        XCTAssertFalse(detector.isCJKV(languageCode: "es-ES"))
    }

    // MARK: - CJKV Language List

    func testCJKVLanguagePrefixes() {
        let detector = CJKVKeyboardDetector()

        XCTAssertEqual(detector.cjkvPrefixes, ["ko", "ja", "vi", "zh"])
    }
}
