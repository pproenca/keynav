// Tests/KeyNavTests/ModeControllerTests.swift
import XCTest
@testable import KeyNav

final class ModeControllerTests: XCTestCase {

    // MARK: - Protocol Conformance

    func testModeControllerProtocolExists() {
        let controller: ModeControllerProtocol = MockModeController()

        XCTAssertNotNil(controller)
    }

    func testModeControllerHasActivateMethod() {
        let controller = MockModeController()

        controller.activate()

        XCTAssertTrue(controller.isActive)
    }

    func testModeControllerHasDeactivateMethod() {
        let controller = MockModeController()
        controller.activate()

        controller.deactivate()

        XCTAssertFalse(controller.isActive)
    }

    func testModeControllerHasIsActiveProperty() {
        let controller = MockModeController()

        XCTAssertFalse(controller.isActive)
    }

    // MARK: - Mode Type

    func testModeControllerHasModeType() {
        let controller = MockModeController()
        controller.mockModeType = .hint

        XCTAssertEqual(controller.modeType, .hint)
    }

    func testModeTypeEnumHasAllModes() {
        XCTAssertEqual(ModeType.hint.rawValue, "hint")
        XCTAssertEqual(ModeType.scroll.rawValue, "scroll")
        XCTAssertEqual(ModeType.normal.rawValue, "normal")
    }

    // MARK: - Input Handling

    func testModeControllerHandlesKeyInput() {
        let controller = MockModeController()
        controller.mockHandleResult = .consumed

        let result = controller.handleKeyInput(keyCode: 0, modifiers: [])

        XCTAssertEqual(result, .consumed)
    }

    func testModeControllerCanPassThroughInput() {
        let controller = MockModeController()
        controller.mockHandleResult = .passThrough

        let result = controller.handleKeyInput(keyCode: 0, modifiers: [])

        XCTAssertEqual(result, .passThrough)
    }

    func testModeControllerCanExitOnInput() {
        let controller = MockModeController()
        controller.mockHandleResult = .exitMode

        let result = controller.handleKeyInput(keyCode: 0, modifiers: [])

        XCTAssertEqual(result, .exitMode)
    }

    // MARK: - Mode Delegate

    func testModeControllerHasDelegate() {
        let controller = MockModeController()
        let delegate = MockModeDelegate()

        controller.delegate = delegate

        XCTAssertNotNil(controller.delegate)
    }

    func testModeControllerNotifiesDelegateOnActivation() {
        let controller = MockModeController()
        let delegate = MockModeDelegate()
        controller.delegate = delegate

        controller.activate()

        XCTAssertTrue(delegate.didActivateCalled)
    }

    func testModeControllerNotifiesDelegateOnDeactivation() {
        let controller = MockModeController()
        let delegate = MockModeDelegate()
        controller.delegate = delegate
        controller.activate()

        controller.deactivate()

        XCTAssertTrue(delegate.didDeactivateCalled)
    }

    // MARK: - Mode Manager

    func testModeManagerRegistersControllers() {
        var manager = ModeManager()
        let controller = MockModeController()

        manager.register(controller: controller, for: .hint)

        XCTAssertNotNil(manager.controller(for: .hint))
    }

    func testModeManagerSwitchesModes() {
        var manager = ModeManager()
        let hintController = MockModeController()
        let scrollController = MockModeController()
        hintController.mockModeType = .hint
        scrollController.mockModeType = .scroll
        manager.register(controller: hintController, for: .hint)
        manager.register(controller: scrollController, for: .scroll)

        manager.switchTo(mode: .scroll)

        XCTAssertEqual(manager.currentMode, .scroll)
    }

    func testModeManagerDeactivatesPreviousMode() {
        var manager = ModeManager()
        let hintController = MockModeController()
        let scrollController = MockModeController()
        hintController.mockModeType = .hint
        scrollController.mockModeType = .scroll
        manager.register(controller: hintController, for: .hint)
        manager.register(controller: scrollController, for: .scroll)
        manager.switchTo(mode: .hint)

        manager.switchTo(mode: .scroll)

        XCTAssertFalse(hintController.isActive)
        XCTAssertTrue(scrollController.isActive)
    }
}

// MARK: - Mock Implementations

class MockModeController: ModeControllerProtocol {
    var isActive: Bool = false
    var mockModeType: ModeType = .normal
    var mockHandleResult: KeyInputResult = .consumed
    weak var delegate: ModeControllerDelegate?

    var modeType: ModeType { mockModeType }

    func activate() {
        isActive = true
        delegate?.modeDidActivate(self)
    }

    func deactivate() {
        isActive = false
        delegate?.modeDidDeactivate(self)
    }

    func handleKeyInput(keyCode: UInt16, modifiers: KeyModifiers) -> KeyInputResult {
        mockHandleResult
    }
}

class MockModeDelegate: ModeControllerDelegate {
    var didActivateCalled = false
    var didDeactivateCalled = false

    func modeDidActivate(_ controller: ModeControllerProtocol) {
        didActivateCalled = true
    }

    func modeDidDeactivate(_ controller: ModeControllerProtocol) {
        didDeactivateCalled = true
    }
}
