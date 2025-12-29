// Tests/KeyNavTests/ScrollModeTests.swift
import XCTest
@testable import KeyNav

final class ScrollModeTests: XCTestCase {

    var scrollMode: ScrollMode!

    override func setUp() {
        super.setUp()
        scrollMode = ScrollMode()
    }

    override func tearDown() {
        scrollMode = nil
        super.tearDown()
    }

    // MARK: - Activation Tests

    func testScrollModeStartsInactive() {
        XCTAssertFalse(scrollMode.isActive)
    }

    func testScrollModeActivate() {
        scrollMode.activate()
        XCTAssertTrue(scrollMode.isActive)
    }

    func testScrollModeDeactivate() {
        scrollMode.activate()
        scrollMode.deactivate()
        XCTAssertFalse(scrollMode.isActive)
    }

    func testScrollModeDoubleActivateNoOp() {
        scrollMode.activate()
        scrollMode.activate()
        XCTAssertTrue(scrollMode.isActive)
    }

    func testScrollModeDoubleDeactivateNoOp() {
        scrollMode.activate()
        scrollMode.deactivate()
        scrollMode.deactivate()
        XCTAssertFalse(scrollMode.isActive)
    }

    // MARK: - Delegate Tests

    func testScrollModeCallsDelegateOnDeactivate() {
        let delegate = MockScrollModeDelegate()
        scrollMode.delegate = delegate
        scrollMode.activate()
        scrollMode.deactivate()
        XCTAssertTrue(delegate.didDeactivate)
    }
}

// MARK: - Test Doubles

private class MockScrollModeDelegate: ScrollModeDelegate {
    var didDeactivate = false

    func scrollModeDidDeactivate() {
        didDeactivate = true
    }
}
