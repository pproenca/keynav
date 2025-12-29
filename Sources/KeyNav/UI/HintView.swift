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

    var hintBackgroundColor: NSColor = NSColor.systemYellow
    var hintTextColor: NSColor = NSColor.black
    var hintFont: NSFont = NSFont.systemFont(ofSize: 12, weight: .bold)
    var hintCornerRadius: CGFloat = 3
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
        let attributes: [NSAttributedString.Key: Any] = [
            .font: hintFont,
            .foregroundColor: hintTextColor
        ]

        let textSize = hint.label.size(withAttributes: attributes)

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

        // Reset shadow
        NSShadow().set()

        // Draw text
        let textPoint = CGPoint(
            x: hintRect.minX + hintPadding,
            y: hintRect.minY + hintPadding
        )
        hint.label.draw(at: textPoint, withAttributes: attributes)
    }
}
