// Sources/KeyNav/UI/HintTextField.swift
import AppKit

/// Protocol for intercepting key events before they go to the text field
protocol HintTextFieldDelegate: NSTextFieldDelegate {
    /// Called when a key is pressed. Return true to consume the event (don't insert into text field).
    func hintTextField(_ textField: HintTextField, shouldConsumeKeyEvent event: NSEvent) -> Bool
}

/// Custom text field that allows intercepting key events for hint selection
final class HintTextField: NSTextField {

    weak var hintDelegate: HintTextFieldDelegate?

    override func keyDown(with event: NSEvent) {
        // Ask delegate if this key should be consumed (for hint selection)
        if let hintDelegate = hintDelegate, hintDelegate.hintTextField(self, shouldConsumeKeyEvent: event) {
            return // Don't pass to super - event consumed
        }

        // Otherwise, handle normally
        super.keyDown(with: event)
    }

    // Override to prevent beep on unhandled keys
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if let hintDelegate = hintDelegate, hintDelegate.hintTextField(self, shouldConsumeKeyEvent: event) {
            return true
        }
        return super.performKeyEquivalent(with: event)
    }
}
