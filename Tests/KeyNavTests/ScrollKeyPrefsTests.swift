// Tests/KeyNavTests/ScrollKeyPrefsTests.swift
import XCTest
@testable import KeyNav

final class ScrollKeyPrefsTests: XCTestCase {

    // MARK: - Default Configuration

    func testDefaultScrollKeyPrefs() {
        let prefs = ScrollKeyPrefs()

        XCTAssertEqual(prefs.keyString, "h,j,k,l,d,u,g,G")
    }

    // MARK: - Custom Configuration

    func testCustomScrollKeyPrefs() {
        let prefs = ScrollKeyPrefs(keyString: "a,s,w,d")

        XCTAssertEqual(prefs.keyString, "a,s,w,d")
    }

    // MARK: - Validation

    func testValid4Keys() {
        XCTAssertTrue(ScrollKeyPrefs.isValid("h,j,k,l"))
    }

    func testValid6Keys() {
        XCTAssertTrue(ScrollKeyPrefs.isValid("h,j,k,l,d,u"))
    }

    func testValid8Keys() {
        XCTAssertTrue(ScrollKeyPrefs.isValid("h,j,k,l,d,u,g,G"))
    }

    func testInvalidKeyCount() {
        XCTAssertFalse(ScrollKeyPrefs.isValid("h,j,k"))      // 3 keys
        XCTAssertFalse(ScrollKeyPrefs.isValid("h,j,k,l,d"))  // 5 keys
        XCTAssertFalse(ScrollKeyPrefs.isValid("h,j,k,l,d,u,g"))  // 7 keys
    }

    func testDuplicateKeysInvalid() {
        XCTAssertFalse(ScrollKeyPrefs.isValid("h,h,k,l"))
    }

    // MARK: - Parsing

    func testParseKeyArray() {
        let prefs = ScrollKeyPrefs(keyString: "a,b,c,d")

        XCTAssertEqual(prefs.keys, ["a", "b", "c", "d"])
    }

    func testParseWithSpaces() {
        let prefs = ScrollKeyPrefs(keyString: "a, b, c, d")

        XCTAssertEqual(prefs.keys, ["a", "b", "c", "d"])
    }
}
