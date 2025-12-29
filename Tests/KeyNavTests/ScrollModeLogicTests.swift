// Tests/KeyNavTests/ScrollModeLogicTests.swift
import XCTest
@testable import KeyNav

final class ScrollModeLogicTests: XCTestCase {

    var logic: ScrollModeLogic!

    override func setUp() {
        super.setUp()
        logic = ScrollModeLogic(smallScrollAmount: 50, pageScrollAmount: 300)
    }

    override func tearDown() {
        logic = nil
        super.tearDown()
    }

    // MARK: - Exit Key Tests

    func testEscapeDeactivates() {
        let result = logic.handleKeyCode(53, characters: nil)
        XCTAssertEqual(result, .deactivate)
    }

    func testCtrlLeftBracketDeactivates() {
        let result = logic.handleKeyCode(33, characters: "[", modifiers: .control)
        XCTAssertEqual(result, .deactivate)
    }

    // MARK: - HJKL Navigation Tests

    func testHScrollsLeft() {
        let result = logic.handleKeyCode(4, characters: "h")
        if case .scroll(let deltaX, let deltaY) = result {
            XCTAssertEqual(deltaX, 50, "H should scroll left (positive deltaX)")
            XCTAssertEqual(deltaY, 0)
        } else {
            XCTFail("Expected scroll result, got \(result)")
        }
    }

    func testJScrollsDown() {
        let result = logic.handleKeyCode(38, characters: "j")
        if case .scroll(let deltaX, let deltaY) = result {
            XCTAssertEqual(deltaX, 0)
            XCTAssertEqual(deltaY, -50, "J should scroll down (negative deltaY)")
        } else {
            XCTFail("Expected scroll result, got \(result)")
        }
    }

    func testKScrollsUp() {
        let result = logic.handleKeyCode(40, characters: "k")
        if case .scroll(let deltaX, let deltaY) = result {
            XCTAssertEqual(deltaX, 0)
            XCTAssertEqual(deltaY, 50, "K should scroll up (positive deltaY)")
        } else {
            XCTFail("Expected scroll result, got \(result)")
        }
    }

    func testLScrollsRight() {
        let result = logic.handleKeyCode(37, characters: "l")
        if case .scroll(let deltaX, let deltaY) = result {
            XCTAssertEqual(deltaX, -50, "L should scroll right (negative deltaX)")
            XCTAssertEqual(deltaY, 0)
        } else {
            XCTFail("Expected scroll result, got \(result)")
        }
    }

    // MARK: - Half-Page Scroll Tests

    func testDScrollsHalfPageDown() {
        let result = logic.handleKeyCode(2, characters: "d")
        if case .scroll(let deltaX, let deltaY) = result {
            XCTAssertEqual(deltaX, 0)
            XCTAssertEqual(deltaY, -300, "D should scroll half-page down")
        } else {
            XCTFail("Expected scroll result, got \(result)")
        }
    }

    func testUScrollsHalfPageUp() {
        let result = logic.handleKeyCode(32, characters: "u")
        if case .scroll(let deltaX, let deltaY) = result {
            XCTAssertEqual(deltaX, 0)
            XCTAssertEqual(deltaY, 300, "U should scroll half-page up")
        } else {
            XCTFail("Expected scroll result, got \(result)")
        }
    }

    // MARK: - gg/G Navigation Tests

    func testGgScrollsToTop() {
        // First 'g' sets waiting state
        let result1 = logic.handleKeyCode(5, characters: "g")
        XCTAssertEqual(result1, .waitingForG)
        XCTAssertTrue(logic.waitingForSecondG)

        // Second 'g' scrolls to top
        let result2 = logic.handleKeyCode(5, characters: "g")
        XCTAssertEqual(result2, .scrollToTop)
        XCTAssertFalse(logic.waitingForSecondG)
    }

    func testShiftGScrollsToBottom() {
        let result = logic.handleKeyCode(5, characters: "g", modifiers: .shift)
        XCTAssertEqual(result, .scrollToBottom)
    }

    func testGWithoutSecondGTimesOut() {
        let result = logic.handleKeyCode(5, characters: "g")
        XCTAssertEqual(result, .waitingForG)
        XCTAssertTrue(logic.waitingForSecondG)

        // Simulate timeout
        logic.cancelWaitingForG()
        XCTAssertFalse(logic.waitingForSecondG)
    }

    func testOtherKeyAfterGCancelsWaiting() {
        // First 'g' sets waiting state
        _ = logic.handleKeyCode(5, characters: "g")
        XCTAssertTrue(logic.waitingForSecondG)

        // Another key cancels waiting
        _ = logic.handleKeyCode(38, characters: "j")
        XCTAssertFalse(logic.waitingForSecondG)
    }

    // MARK: - Case Insensitivity Tests

    func testHJKLCaseInsensitive() {
        // Uppercase should work the same
        let resultH = logic.handleKeyCode(4, characters: "H")
        if case .scroll(let deltaX, _) = resultH {
            XCTAssertEqual(deltaX, 50)
        } else {
            XCTFail("H should scroll")
        }
    }

    // MARK: - Invalid Input Tests

    func testUnknownKeyReturnsIgnored() {
        let result = logic.handleKeyCode(0, characters: "x")
        XCTAssertEqual(result, .ignored)
    }

    func testEmptyCharactersReturnsIgnored() {
        let result = logic.handleKeyCode(0, characters: "")
        XCTAssertEqual(result, .ignored)
    }

    func testNilCharactersReturnsIgnored() {
        let result = logic.handleKeyCode(0, characters: nil)
        XCTAssertEqual(result, .ignored)
    }

    // MARK: - Reset Tests

    func testResetClearsWaitingState() {
        _ = logic.handleKeyCode(5, characters: "g")
        XCTAssertTrue(logic.waitingForSecondG)

        logic.reset()
        XCTAssertFalse(logic.waitingForSecondG)
    }

    // MARK: - Custom Scroll Amount Tests

    func testCustomScrollAmounts() {
        let customLogic = ScrollModeLogic(smallScrollAmount: 100, pageScrollAmount: 500)

        let smallResult = customLogic.handleKeyCode(38, characters: "j")
        if case .scroll(_, let deltaY) = smallResult {
            XCTAssertEqual(deltaY, -100)
        } else {
            XCTFail("Expected scroll result")
        }

        let pageResult = customLogic.handleKeyCode(2, characters: "d")
        if case .scroll(_, let deltaY) = pageResult {
            XCTAssertEqual(deltaY, -500)
        } else {
            XCTFail("Expected scroll result")
        }
    }
}
