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
    private let hintGenerator = HintLabelGenerator()
    private let fuzzyMatcher = FuzzyMatcher()

    private var overlayWindow: OverlayWindow?
    private var hintView: HintView?
    private var searchBarView: SearchBarView?

    private var elements: [ActionableElement] = []
    private var filteredElements: [ActionableElement] = []
    private var hintLabels: [String] = []
    private var currentQuery = ""
    private var typedHintChars = ""

    func activate() {
        guard !isActive else { return }
        isActive = true

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
        elements = []
        filteredElements = []
        hintLabels = []
        currentQuery = ""
        typedHintChars = ""

        delegate?.hintModeDidDeactivate()
    }

    func handleKeyDown(_ event: NSEvent) -> Bool {
        guard isActive else { return false }

        // Escape to cancel
        if event.keyCode == 53 {
            deactivate()
            return true
        }

        // Backspace
        if event.keyCode == 51 {
            if !typedHintChars.isEmpty {
                typedHintChars.removeLast()
            } else if !currentQuery.isEmpty {
                currentQuery.removeLast()
                updateFilteredElements()
            }
            updateHints()
            return true
        }

        // Regular character
        if let chars = event.characters?.uppercased(), chars.count == 1 {
            let char = chars.first!

            // Check if this could be part of a hint
            if isHintChar(char) && !filteredElements.isEmpty {
                typedHintChars.append(char)

                // Check for hint match
                if let index = hintLabels.firstIndex(of: typedHintChars) {
                    let element = filteredElements[index]
                    selectElement(element)
                    return true
                }

                // Check if this could still match
                let possibleMatches = hintLabels.filter { $0.hasPrefix(typedHintChars) }
                if possibleMatches.isEmpty {
                    // Not a hint, treat as search query
                    typedHintChars = ""
                    currentQuery.append(Character(chars.lowercased()))
                    updateFilteredElements()
                }

                updateHints()
                return true
            } else {
                // Search character
                currentQuery.append(Character(chars.lowercased()))
                typedHintChars = ""
                updateFilteredElements()
                updateHints()
                return true
            }
        }

        return false
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
            self?.elements = elements
            self?.filteredElements = elements
            self?.updateHints()
        }
    }

    private func updateFilteredElements() {
        filteredElements = fuzzyMatcher.filterAndSort(elements: elements, query: currentQuery)
        typedHintChars = ""

        // Auto-select if single match
        if filteredElements.count == 1 && !currentQuery.isEmpty {
            selectElement(filteredElements[0])
        }
    }

    private func updateHints() {
        hintLabels = hintGenerator.generate(count: filteredElements.count)

        let hints = zip(filteredElements, hintLabels).map { element, label -> HintViewModel in
            let matchRange = fuzzyMatcher.matchRange(query: currentQuery, in: element.label)
            return HintViewModel(
                label: label,
                frame: element.frame,
                matchedRange: matchRange
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
        currentQuery = text.lowercased()
        typedHintChars = ""
        updateFilteredElements()
        updateHints()
    }

    func searchBarDidPressEscape() {
        deactivate()
    }

    func searchBarDidPressEnter() {
        if let first = filteredElements.first {
            selectElement(first)
        }
    }

    func searchBarDidPressArrowUp() {
        // Could implement selection cycling
    }

    func searchBarDidPressArrowDown() {
        // Could implement selection cycling
    }
}
