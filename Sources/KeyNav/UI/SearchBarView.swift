// Sources/KeyNav/UI/SearchBarView.swift
import AppKit

protocol SearchBarViewDelegate: AnyObject {
    func searchBarDidChangeText(_ text: String)
    func searchBarDidPressEscape()
    func searchBarDidPressEnter()
    func searchBarDidPressArrowUp()
    func searchBarDidPressArrowDown()
}

final class SearchBarView: NSView {
    weak var delegate: SearchBarViewDelegate?

    private let textField: NSTextField = {
        let field = NSTextField()
        field.placeholderString = "Type to search..."
        field.font = NSFont.systemFont(ofSize: 18)
        field.isBezeled = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let containerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        view.layer?.cornerRadius = 10
        view.layer?.shadowColor = NSColor.black.cgColor
        view.layer?.shadowOpacity = 0.3
        view.layer?.shadowOffset = CGSize(width: 0, height: -2)
        view.layer?.shadowRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var text: String {
        get { textField.stringValue }
        set { textField.stringValue = newValue }
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
        containerView.addSubview(textField)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 400),
            containerView.heightAnchor.constraint(equalToConstant: 50),

            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        textField.delegate = self
    }

    func focus() {
        window?.makeFirstResponder(textField)
    }

    func clear() {
        textField.stringValue = ""
    }
}

extension SearchBarView: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        delegate?.searchBarDidChangeText(textField.stringValue)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            delegate?.searchBarDidPressEscape()
            return true
        }
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            delegate?.searchBarDidPressEnter()
            return true
        }
        if commandSelector == #selector(NSResponder.moveUp(_:)) {
            delegate?.searchBarDidPressArrowUp()
            return true
        }
        if commandSelector == #selector(NSResponder.moveDown(_:)) {
            delegate?.searchBarDidPressArrowDown()
            return true
        }
        return false
    }
}
