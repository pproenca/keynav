// Sources/KeyNav/Core/Modes/HintMode.swift
import AppKit

protocol HintModeDelegate: AnyObject {
    func hintModeDidDeactivate()
    func hintModeDidSelectElement(_ element: ActionableElement, clickType: ClickType)
}

final class HintMode: Mode, KeyboardEventCaptureDelegate {
    let type: ModeType = .hint
    private(set) var isActive = false

    weak var delegate: HintModeDelegate?

    private let accessibilityEngine: AccessibilityEngineProtocol
    private let keyboardCapture: KeyboardEventCapture
    private let logic = HintModeLogic()

    private var overlayWindow: OverlayWindow?
    private var hintView: HintView?
    private var inputDisplayView: InputDisplayView?

    /// Default initializer for production use
    convenience init() {
        self.init(
            accessibilityEngine: AccessibilityEngine(),
            keyboardCapture: GlobalKeyboardEventCapture()
        )
    }

    /// Initializer with dependency injection for testing
    init(accessibilityEngine: AccessibilityEngineProtocol, keyboardCapture: KeyboardEventCapture) {
        self.accessibilityEngine = accessibilityEngine
        self.keyboardCapture = keyboardCapture
        self.keyboardCapture.delegate = self
    }

    func activate() {
        guard !isActive else { return }
        isActive = true
        logic.reset()

        CursorManager.shared.hideCursor()
        setupOverlay()
        keyboardCapture.startCapturing()
        loadElements()
    }

    func deactivate() {
        guard isActive else { return }
        isActive = false

        CursorManager.shared.showCursor()
        keyboardCapture.stopCapturing()
        overlayWindow?.dismiss()
        overlayWindow = nil
        hintView = nil
        inputDisplayView = nil
        logic.reset()

        delegate?.hintModeDidDeactivate()
    }

    func handleKeyDown(_ event: NSEvent) -> Bool {
        // Not used anymore - we use keyboardCapture instead
        return false
    }

    // MARK: - KeyboardEventCaptureDelegate

    func keyboardEventCapture(_ capture: KeyboardEventCapture, didReceiveKeyDown keyCode: UInt16, characters: String?, modifiers: KeyModifiers) -> Bool {
        guard isActive else { return false }

        let result = logic.handleKeyCode(keyCode, characters: characters, modifiers: modifiers)
        return processResult(result)
    }

    // MARK: - Private

    private func processResult(_ result: HintModeLogic.KeyResult) -> Bool {
        switch result {
        case .ignored:
            return false
        case .handled:
            updateDisplay()
            return true
        case .deactivate:
            deactivate()
            return true
        case .selectElement(let element, let clickType):
            selectElement(element, clickType: clickType)
            return true
        }
    }

    private func setupOverlay() {
        overlayWindow = OverlayWindow()

        let contentView = NSView(frame: overlayWindow!.frame)

        hintView = HintView(frame: contentView.bounds)
        hintView?.autoresizingMask = [.width, .height]
        contentView.addSubview(hintView!)

        inputDisplayView = InputDisplayView(frame: contentView.bounds)
        inputDisplayView?.autoresizingMask = [.width, .height]
        contentView.addSubview(inputDisplayView!)

        overlayWindow?.contentView = contentView
        overlayWindow?.show()
    }

    private func loadElements() {
        accessibilityEngine.getActionableElements { [weak self] elements in
            guard let self = self else { return }
            self.logic.setElements(elements)
            self.updateDisplay()
        }
    }

    private func updateDisplay() {
        // Update hint display
        let hints = zip(logic.filteredElements, logic.hintLabels).map { element, label -> HintViewModel in
            // Highlight matched portion of hint
            let typedCount = logic.typedHintChars.count
            let matchedRange: Range<String.Index>? = typedCount > 0 ? label.startIndex..<label.index(label.startIndex, offsetBy: min(typedCount, label.count)) : nil
            return HintViewModel(
                label: label,
                frame: element.frame,
                matchedRange: matchedRange
            )
        }
        hintView?.updateHints(hints)

        // Update input display
        inputDisplayView?.text = logic.typedHintChars
    }

    private func selectElement(_ element: ActionableElement, clickType: ClickType) {
        deactivate()
        switch clickType {
        case .leftClick:
            accessibilityEngine.performClick(on: element)
        case .rightClick:
            accessibilityEngine.performRightClick(on: element)
        case .doubleClick:
            accessibilityEngine.performDoubleClick(on: element)
        case .moveOnly:
            accessibilityEngine.moveMouse(to: element)
        }
        delegate?.hintModeDidSelectElement(element, clickType: clickType)
    }
}
