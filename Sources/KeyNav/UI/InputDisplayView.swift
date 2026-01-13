// Sources/KeyNav/UI/InputDisplayView.swift
import AppKit

/// A simple non-editable view that displays typed input.
/// Unlike a text field, this doesn't capture focus and allows menus to stay open.
final class InputDisplayView: NSView {
    private let label: NSTextField = {
        let field = NSTextField(labelWithString: "")
        field.font = NSFont.monospacedSystemFont(ofSize: 24, weight: .medium)
        field.textColor = AppearanceColors.inputDisplayText
        field.alignment = .center
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let containerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var text: String = "" {
        didSet {
            label.stringValue = text
            containerView.isHidden = text.isEmpty
            updateAccessibility()
        }
    }

    private func updateAccessibility() {
        if text.isEmpty {
            setAccessibilityLabel("No input")
        } else {
            setAccessibilityLabel("Typed: \(text)")
            setAccessibilityValue(text)
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(containerView)
        containerView.addSubview(label)

        // Set background color using layer - this supports dynamic colors
        containerView.layer?.backgroundColor = AppearanceColors.inputDisplayBackground.cgColor

        // Configure accessibility
        setAccessibilityElement(true)
        setAccessibilityRole(.staticText)
        setAccessibilityRoleDescription("Typed hint characters")
        setAccessibilityLabel("No input")

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            containerView.heightAnchor.constraint(equalToConstant: 50),

            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])

        containerView.isHidden = true
    }
}
