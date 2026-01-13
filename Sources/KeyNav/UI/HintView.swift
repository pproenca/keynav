// Sources/KeyNav/UI/HintView.swift
import AppKit

struct HintViewModel {
    let label: String
    let frame: CGRect
    let matchedRange: Range<String.Index>?

    init(label: String, frame: CGRect, matchedRange: Range<String.Index>? = nil) {
        self.label = label
        self.frame = frame
        self.matchedRange = matchedRange
    }
}

final class HintView: NSView {
    private var hints: [HintViewModel] = []

    // Enable layer-backed rendering for GPU acceleration
    override var wantsLayer: Bool {
        get { true }
        set {}
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.drawsAsynchronously = true
        setupAccessibility()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer?.drawsAsynchronously = true
        setupAccessibility()
    }

    private func setupAccessibility() {
        setAccessibilityElement(true)
        setAccessibilityRole(.group)
        setAccessibilityRoleDescription("Keyboard navigation hints")
    }

    // MARK: - Accessibility

    override func accessibilityLabel() -> String? {
        guard !hints.isEmpty else { return "No hints available" }
        return "\(hints.count) keyboard hints displayed"
    }

    override func accessibilityChildren() -> [Any]? {
        // Expose each hint as an accessible element
        return hints.enumerated().map { index, hint in
            HintAccessibilityElement(hint: hint, index: index, parent: self)
        }
    }

    /// Background color: appearance-aware (pale yellow in light mode, muted gold in dark mode)
    var hintBackgroundColor: NSColor = AppearanceColors.hintBackground
    /// Unmatched (untyped) text color: appearance-aware
    var hintTextColor: NSColor = AppearanceColors.hintText
    /// Matched (typed) text color: appearance-aware golden
    var hintMatchedTextColor: NSColor = AppearanceColors.hintMatchedText
    /// Font size: 11pt bold (Vimac default)
    var hintFont: NSFont = NSFont.systemFont(ofSize: 11, weight: .bold)
    var hintCornerRadius: CGFloat = 3
    var hintBorderWidth: CGFloat = 1.0
    var hintPadding: CGFloat = 4

    func updateHints(_ hints: [HintViewModel]) {
        self.hints = hints
        needsDisplay = true
    }

    func clear() {
        hints = []
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        for hint in hints {
            drawHint(hint)
        }
    }

    private func drawHint(_ hint: HintViewModel) {
        // Create attributed string with different colors for matched vs unmatched text
        let attributedString = createAttributedString(for: hint)

        let textSize = attributedString.size()

        let hintRect = CGRect(
            x: hint.frame.minX,
            y: bounds.height - hint.frame.minY - textSize.height - hintPadding * 2,
            width: textSize.width + hintPadding * 2,
            height: textSize.height + hintPadding * 2
        )

        // Draw background
        let backgroundPath = NSBezierPath(roundedRect: hintRect, xRadius: hintCornerRadius, yRadius: hintCornerRadius)

        // Shadow (simplified for better performance)
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.2)
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 1
        shadow.set()

        hintBackgroundColor.setFill()
        backgroundPath.fill()

        // Reset shadow for border and text
        NSShadow().set()

        // Draw border
        AppearanceColors.hintBorder.setStroke()
        backgroundPath.lineWidth = hintBorderWidth
        backgroundPath.stroke()

        // Draw text
        let textPoint = CGPoint(
            x: hintRect.minX + hintPadding,
            y: hintRect.minY + hintPadding
        )
        attributedString.draw(at: textPoint)
    }

    /// Creates an attributed string with matched characters in golden brown and unmatched in black
    private func createAttributedString(for hint: HintViewModel) -> NSAttributedString {
        let label = hint.label

        // Default attributes for unmatched text
        let unmatchedAttributes: [NSAttributedString.Key: Any] = [
            .font: hintFont,
            .foregroundColor: hintTextColor
        ]

        // If no matched range, return all text in default color
        guard let matchedRange = hint.matchedRange else {
            return NSAttributedString(string: label, attributes: unmatchedAttributes)
        }

        // Matched attributes (golden brown)
        let matchedAttributes: [NSAttributedString.Key: Any] = [
            .font: hintFont,
            .foregroundColor: hintMatchedTextColor
        ]

        let attributedString = NSMutableAttributedString(string: label, attributes: unmatchedAttributes)

        // Convert String.Index range to NSRange
        let nsRange = NSRange(matchedRange, in: label)
        attributedString.setAttributes(matchedAttributes, range: nsRange)

        return attributedString
    }
}

// MARK: - Accessibility Element for Individual Hints

/// Represents a single hint as an accessibility element for VoiceOver.
private class HintAccessibilityElement: NSAccessibilityElement {
    private let hint: HintViewModel
    private let index: Int
    private weak var parentView: HintView?

    init(hint: HintViewModel, index: Int, parent: HintView) {
        self.hint = hint
        self.index = index
        self.parentView = parent
        super.init()

        setAccessibilityRole(.button)
        setAccessibilityRoleDescription("Hint key")
        setAccessibilityParent(parent)
    }

    override func accessibilityLabel() -> String? {
        "Press \(hint.label) to activate"
    }

    override func accessibilityFrame() -> NSRect {
        guard let parent = parentView else { return .zero }
        // Convert hint frame to screen coordinates
        let windowFrame = parent.window?.frame ?? .zero
        let viewFrame = parent.convert(hint.frame, to: nil)
        return NSRect(
            x: windowFrame.origin.x + viewFrame.origin.x,
            y: windowFrame.origin.y + viewFrame.origin.y,
            width: viewFrame.width,
            height: viewFrame.height
        )
    }

    override func accessibilityIndex() -> Int {
        index
    }
}
