// Sources/KeyNav/UI/HintsPreferencesView.swift
import AppKit

/// Delegate protocol for HintsPreferencesView actions
protocol HintsPreferencesDelegate: AnyObject {
    func hintsPreferencesDidChangeCharacters(_ characters: String)
    func hintsPreferencesDidChangeTextSize(_ size: CGFloat)
}

/// Builder class for the Hints preferences tab view
final class HintsPreferencesViewBuilder {
    weak var delegate: HintsPreferencesDelegate?

    private weak var sizeValueLabel: NSTextField?

    func createView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 350))

        var y: CGFloat = 290

        // Title
        y = addTitle(to: view, at: y)

        // Character Set row
        y = addCharacterSetRow(to: view, at: y)

        // Text Size row
        addTextSizeRow(to: view, at: y)

        return view
    }

    // MARK: - View Building Helpers

    private func addTitle(to view: NSView, at y: CGFloat) -> CGFloat {
        let titleLabel = createLabel("Hint Settings", bold: true)
        titleLabel.frame = NSRect(x: 20, y: y, width: 460, height: 20)
        view.addSubview(titleLabel)
        return y - 40
    }

    private func addCharacterSetRow(to view: NSView, at y: CGFloat) -> CGFloat {
        let charLabel = createLabel("Hint Characters:")
        charLabel.frame = NSRect(x: 20, y: y, width: 120, height: 25)
        view.addSubview(charLabel)

        let charField = NSTextField(frame: NSRect(x: 150, y: y, width: 200, height: 25))
        charField.stringValue = Configuration.shared.hintCharacters
        charField.tag = 10
        charField.target = self
        charField.action = #selector(hintCharactersChanged(_:))
        charField.setAccessibilityLabel("Hint characters")
        charField.setAccessibilityRoleDescription("Characters used for keyboard hint labels")
        view.addSubview(charField)

        let hintY = y - 30
        let charHint = createLabel("Characters used for hint labels (e.g., 'sadfjklewcmpgh')")
        charHint.frame = NSRect(x: 150, y: hintY, width: 300, height: 20)
        charHint.textColor = .secondaryLabelColor
        charHint.font = NSFont.systemFont(ofSize: 11)
        view.addSubview(charHint)

        return hintY - 10
    }

    private func addTextSizeRow(to view: NSView, at y: CGFloat) {
        let sizeLabel = createLabel("Hint Text Size:")
        sizeLabel.frame = NSRect(x: 20, y: y, width: 120, height: 25)
        view.addSubview(sizeLabel)

        let currentSize = Configuration.shared.hintTextSize

        let sizeSlider = NSSlider(frame: NSRect(x: 150, y: y, width: 150, height: 25))
        sizeSlider.minValue = 8
        sizeSlider.maxValue = 20
        sizeSlider.doubleValue = Double(currentSize)
        sizeSlider.target = self
        sizeSlider.action = #selector(hintSizeChanged(_:))
        sizeSlider.setAccessibilityLabel("Hint text size")
        sizeSlider.setAccessibilityValue("\(Int(currentSize)) points")
        view.addSubview(sizeSlider)

        let sizeValueLabel = createLabel("\(Int(currentSize)) pt")
        sizeValueLabel.frame = NSRect(x: 310, y: y, width: 50, height: 25)
        sizeValueLabel.tag = 11
        view.addSubview(sizeValueLabel)
        self.sizeValueLabel = sizeValueLabel
    }

    // MARK: - UI Component Builders

    private func createLabel(_ text: String, bold: Bool = false) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        if bold {
            label.font = NSFont.boldSystemFont(ofSize: 13)
        }
        return label
    }

    // MARK: - Actions

    @objc private func hintCharactersChanged(_ sender: NSTextField) {
        let newChars = sender.stringValue
        if !newChars.isEmpty && HintCharacterPrefs.isValid(newChars) {
            delegate?.hintsPreferencesDidChangeCharacters(newChars)
        }
    }

    @objc private func hintSizeChanged(_ sender: NSSlider) {
        let newSize = CGFloat(sender.doubleValue)
        delegate?.hintsPreferencesDidChangeTextSize(newSize)

        // Update the label
        sizeValueLabel?.stringValue = "\(Int(newSize)) pt"
    }
}
