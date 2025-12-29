// Sources/KeyNav/Core/Modes/HintMode.swift
import AppKit

protocol HintModeDelegate: AnyObject {
    func hintModeDidDeactivate()
    func hintModeDidSelectElement(_ element: ActionableElement)
}

final class HintMode: Mode {
    let type: ModeType = .hint
    private(set) var isActive = false

    weak var delegate: HintModeDelegate?

    private let accessibilityEngine = AccessibilityEngine()
    private let logic = HintModeLogic()

    private var overlayWindow: OverlayWindow?
    private var hintView: HintView?
    private var searchBarView: SearchBarView?

    func activate() {
        guard !isActive else { return }
        isActive = true
        logic.reset()

        setupOverlay()
        loadElements()
    }

    func deactivate() {
        guard isActive else { return }
        isActive = false

        overlayWindow?.dismiss()
        overlayWindow = nil
        hintView = nil
        searchBarView = nil
        logic.reset()

        delegate?.hintModeDidDeactivate()
    }

    func handleKeyDown(_ event: NSEvent) -> Bool {
        guard isActive else { return false }

        let result = logic.handleKeyCode(event.keyCode, characters: event.characters)
        return processResult(result)
    }

    private func processResult(_ result: HintModeLogic.KeyResult) -> Bool {
        switch result {
        case .ignored:
            return false
        case .handled:
            updateHintDisplay()
            return true
        case .deactivate:
            deactivate()
            return true
        case .selectElement(let element):
            selectElement(element)
            return true
        }
    }

    private func setupOverlay() {
        overlayWindow = OverlayWindow()

        let contentView = NSView(frame: overlayWindow!.frame)

        hintView = HintView(frame: contentView.bounds)
        hintView?.autoresizingMask = [.width, .height]
        contentView.addSubview(hintView!)

        searchBarView = SearchBarView(frame: CGRect(x: 0, y: contentView.bounds.height - 100, width: contentView.bounds.width, height: 100))
        searchBarView?.autoresizingMask = [.width, .minYMargin]
        searchBarView?.delegate = self
        contentView.addSubview(searchBarView!)

        overlayWindow?.contentView = contentView
        overlayWindow?.show()
        searchBarView?.focus()
    }

    private func loadElements() {
        accessibilityEngine.getActionableElements { [weak self] elements in
            guard let self = self else { return }
            self.logic.setElements(elements)
            self.updateHintDisplay()
        }
    }

    private func updateHintDisplay() {
        let hints = zip(logic.filteredElements, logic.hintLabels).map { element, label -> HintViewModel in
            return HintViewModel(
                label: label,
                frame: element.frame,
                matchedRange: nil
            )
        }
        hintView?.updateHints(hints)
    }

    private func selectElement(_ element: ActionableElement) {
        deactivate()
        accessibilityEngine.performClick(on: element)
        delegate?.hintModeDidSelectElement(element)
    }

    private func isHintChar(_ char: Character) -> Bool {
        "ASDFGHJKLQWERUIO".contains(char)
    }
}

extension HintMode: SearchBarViewDelegate {
    func searchBarDidChangeText(_ text: String) {
        if let result = logic.handleSearchTextChange(text) {
            _ = processResult(result)
        } else {
            updateHintDisplay()
        }
    }

    func searchBarDidPressEscape() {
        deactivate()
    }

    func searchBarDidPressEnter() {
        if let result = logic.handleEnter() {
            _ = processResult(result)
        }
    }

    func searchBarDidPressArrowUp() {
        // Could implement selection cycling
    }

    func searchBarDidPressArrowDown() {
        // Could implement selection cycling
    }

    func searchBarShouldConsumeKeyEvent(_ event: NSEvent) -> Bool {
        guard isActive else { return false }

        // Check if this is a hint character that matches a current hint
        guard let chars = event.characters?.uppercased(), chars.count == 1, let char = chars.first else {
            return false
        }

        // Only intercept hint chars when search field is empty or we're building a hint sequence
        if isHintChar(char) && logic.filteredElements.count > 0 {
            // Check if this char would match or could match a hint
            let potentialHint = logic.typedHintChars + String(char)

            // Check for exact match
            if logic.hintLabels.contains(potentialHint) {
                let result = logic.handleKeyCode(event.keyCode, characters: event.characters)
                _ = processResult(result)
                return true
            }

            // Check if could be prefix of a longer hint
            let couldMatch = logic.hintLabels.contains { $0.hasPrefix(potentialHint) }
            if couldMatch {
                let result = logic.handleKeyCode(event.keyCode, characters: event.characters)
                _ = processResult(result)
                return true
            }
        }

        // Let the character go to the text field for search
        return false
    }
}
