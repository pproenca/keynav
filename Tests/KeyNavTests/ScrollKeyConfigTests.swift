// Tests/KeyNavTests/ScrollKeyConfigTests.swift
import XCTest
@testable import KeyNav

final class ScrollKeyConfigTests: XCTestCase {

    // MARK: - Default Configuration Tests

    func testDefaultScrollKeysAreVimStyle() {
        let config = ScrollKeyConfig()

        XCTAssertEqual(config.left, "h")
        XCTAssertEqual(config.down, "j")
        XCTAssertEqual(config.up, "k")
        XCTAssertEqual(config.right, "l")
        XCTAssertEqual(config.halfPageDown, "d")
        XCTAssertEqual(config.halfPageUp, "u")
        XCTAssertEqual(config.toTop, "g")  // gg
        XCTAssertEqual(config.toBottom, "G")  // Shift+G
    }

    func testScrollModeLogicUsesDefaultConfig() {
        let logic = ScrollModeLogic()

        // Test default HJKL keys work
        XCTAssertEqual(logic.handleKeyCode(0, characters: "h", modifiers: []),
                       .scroll(deltaX: 50, deltaY: 0))
        XCTAssertEqual(logic.handleKeyCode(0, characters: "j", modifiers: []),
                       .scroll(deltaX: 0, deltaY: -50))
    }

    // MARK: - Custom Configuration Tests

    func testScrollModeLogicWithCustomKeys() {
        let config = ScrollKeyConfig(
            left: "a",
            down: "s",
            up: "w",
            right: "d",
            halfPageDown: "f",
            halfPageUp: "e"
        )
        let logic = ScrollModeLogic(keyConfig: config)

        // WASD should work
        XCTAssertEqual(logic.handleKeyCode(0, characters: "a", modifiers: []),
                       .scroll(deltaX: 50, deltaY: 0))
        XCTAssertEqual(logic.handleKeyCode(0, characters: "s", modifiers: []),
                       .scroll(deltaX: 0, deltaY: -50))
        XCTAssertEqual(logic.handleKeyCode(0, characters: "w", modifiers: []),
                       .scroll(deltaX: 0, deltaY: 50))
        XCTAssertEqual(logic.handleKeyCode(0, characters: "d", modifiers: []),
                       .scroll(deltaX: -50, deltaY: 0))

        // Original HJKL should be ignored
        XCTAssertEqual(logic.handleKeyCode(0, characters: "h", modifiers: []),
                       .ignored)
    }

    func testScrollKeyConfigFromString() {
        // Parse config from comma-separated string like Vimac
        let config = ScrollKeyConfig.fromString("a,s,w,d,f,e,g,G")

        XCTAssertEqual(config?.left, "a")
        XCTAssertEqual(config?.down, "s")
        XCTAssertEqual(config?.up, "w")
        XCTAssertEqual(config?.right, "d")
        XCTAssertEqual(config?.halfPageDown, "f")
        XCTAssertEqual(config?.halfPageUp, "e")
    }

    func testScrollKeyConfigFromInvalidStringReturnsNil() {
        // Too few keys
        XCTAssertNil(ScrollKeyConfig.fromString("a,b,c"))

        // Empty string
        XCTAssertNil(ScrollKeyConfig.fromString(""))
    }

    func testScrollKeyConfigValidation() {
        // Valid config
        let validConfig = ScrollKeyConfig()
        XCTAssertTrue(validConfig.isValid)

        // Config with duplicate keys would be invalid
        let invalidConfig = ScrollKeyConfig(
            left: "a",
            down: "a",  // duplicate
            up: "w",
            right: "d"
        )
        XCTAssertFalse(invalidConfig.isValid)
    }

    func testScrollKeyConfigToString() {
        let config = ScrollKeyConfig()
        let stringRepresentation = config.toString()

        XCTAssertEqual(stringRepresentation, "h,j,k,l,d,u,g,G")
    }
}
