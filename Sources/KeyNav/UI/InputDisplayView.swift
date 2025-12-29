// Sources/KeyNav/UI/InputDisplayView.swift
import AppKit

/// A simple non-editable view that displays typed input.
/// Unlike a text field, this doesn't capture focus and allows menus to stay open.
final class InputDisplayView: NSView {
    private let label: NSTextField = {
        let field = NSTextField(labelWithString: "")
        field.font = NSFont.monospacedSystemFont(ofSize: 24, weight: .medium)
        field.textColor = .white
        field.alignment = .center
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let containerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.8).cgColor
        view.layer?.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var text: String = "" {
        didSet {
            label.stringValue = text
            containerView.isHidden = text.isEmpty
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

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            containerView.heightAnchor.constraint(equalToConstant: 50),

            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        containerView.isHidden = true
    }
}
