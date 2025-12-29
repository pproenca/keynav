// Tests/KeyNavTests/InputSourceSwitchingTests.swift
import XCTest
@testable import KeyNav

final class InputSourceSwitchingTests: XCTestCase {

    // MARK: - Shortcut Plist Key

    func testShortcutPlistDomain() {
        let switcher = InputSourceSwitcher()

        XCTAssertEqual(switcher.shortcutDomain, "com.apple.symbolichotkeys")
    }

    // MARK: - Shortcut Key IDs

    func testSwitchInputSourceKeyID() {
        let switcher = InputSourceSwitcher()

        // ID 60 = Select next input source
        XCTAssertEqual(switcher.nextInputSourceKeyID, 60)
    }

    func testSwitchPreviousInputSourceKeyID() {
        let switcher = InputSourceSwitcher()

        // ID 61 = Select previous input source
        XCTAssertEqual(switcher.previousInputSourceKeyID, 61)
    }

    // MARK: - Shortcut Parsing

    func testParseShortcutModifiers() {
        let switcher = InputSourceSwitcher()

        // 131072 = Shift modifier flag
        let modifiers = switcher.parseModifiers(131072)

        XCTAssertTrue(modifiers.contains(.shift))
    }

    // MARK: - State Management

    func testInitialSourceIsNil() {
        let switcher = InputSourceSwitcher()

        XCTAssertNil(switcher.originalSource)
    }

    func testSaveOriginalSource() {
        var switcher = InputSourceSwitcher()

        switcher.saveOriginalSource("com.apple.keylayout.US")

        XCTAssertEqual(switcher.originalSource, "com.apple.keylayout.US")
    }

    func testClearOriginalSource() {
        var switcher = InputSourceSwitcher()

        switcher.saveOriginalSource("com.apple.keylayout.US")
        switcher.clearOriginalSource()

        XCTAssertNil(switcher.originalSource)
    }
}
