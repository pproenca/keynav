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

    /// Background color: pale yellow RGB(255, 224, 112)
    var hintBackgroundColor: NSColor = NSColor(calibratedRed: 255/255.0, green: 224/255.0, blue: 112/255.0, alpha: 1.0)
    /// Unmatched (untyped) text color: black
    var hintTextColor: NSColor = NSColor.black
    /// Matched (typed) text color: golden brown RGB(212, 172, 58)
    var hintMatchedTextColor: NSColor = NSColor(calibratedRed: 212/255.0, green: 172/255.0, blue: 58/255.0, alpha: 1.0)
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

        // Shadow
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 3
        shadow.set()

        hintBackgroundColor.setFill()
        backgroundPath.fill()

        // Reset shadow for border and text
        NSShadow().set()

        // Draw border
        NSColor.darkGray.setStroke()
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
