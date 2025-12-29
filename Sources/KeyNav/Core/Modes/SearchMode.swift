// Sources/KeyNav/Core/Modes/SearchMode.swift
import AppKit

protocol SearchModeDelegate: AnyObject {
    func searchModeDidDeactivate()
    func searchModeDidSelectElement(_ element: ActionableElement)
}

final class SearchMode: Mode {
    let type: ModeType = .search
    private(set) var isActive = false

    weak var delegate: SearchModeDelegate?

    private let accessibilityEngine = AccessibilityEngine()
    private let fuzzyMatcher = FuzzyMatcher()

    private var overlayWindow: OverlayWindow?
    private var searchView: SearchResultsView?

    private var allElements: [ActionableElement] = []
    private var filteredElements: [ActionableElement] = []
    private var selectedIndex = 0

    func activate() {
        guard !isActive else { return }
        isActive = true

        setupOverlay()
        loadAllElements()
    }

    func deactivate() {
        guard isActive else { return }
        isActive = false

        overlayWindow?.dismiss()
        overlayWindow = nil
        searchView = nil
        allElements = []
        filteredElements = []
        selectedIndex = 0

        delegate?.searchModeDidDeactivate()
    }

    func handleKeyDown(_ event: NSEvent) -> Bool {
        guard isActive else { return false }

        // Escape to cancel
        if event.keyCode == 53 {
            deactivate()
            return true
        }

        return false
    }

    private func setupOverlay() {
        overlayWindow = OverlayWindow()

        let contentView = NSView(frame: overlayWindow!.frame)

        searchView = SearchResultsView(frame: contentView.bounds)
        searchView?.delegate = self
        contentView.addSubview(searchView!)

        overlayWindow?.contentView = contentView
        overlayWindow?.show()
        searchView?.focus()
    }

    private func loadAllElements() {
        accessibilityEngine.getAllWindowElements { [weak self] elements in
            self?.allElements = elements
            self?.filteredElements = elements
            self?.searchView?.updateResults(elements)
        }
    }

    private func updateFilteredElements(query: String) {
        filteredElements = fuzzyMatcher.filterAndSort(elements: allElements, query: query)
        selectedIndex = 0
        searchView?.updateResults(filteredElements)
    }

    private func selectCurrentElement() {
        guard selectedIndex < filteredElements.count else { return }
        let element = filteredElements[selectedIndex]
        deactivate()
        accessibilityEngine.performClick(on: element)
        delegate?.searchModeDidSelectElement(element)
    }
}

extension SearchMode: SearchResultsViewDelegate {
    func searchResultsDidChangeQuery(_ query: String) {
        updateFilteredElements(query: query)
    }

    func searchResultsDidPressEscape() {
        deactivate()
    }

    func searchResultsDidPressEnter() {
        selectCurrentElement()
    }

    func searchResultsDidSelectIndex(_ index: Int) {
        selectedIndex = index
    }
}

// MARK: - SearchResultsView

protocol SearchResultsViewDelegate: AnyObject {
    func searchResultsDidChangeQuery(_ query: String)
    func searchResultsDidPressEscape()
    func searchResultsDidPressEnter()
    func searchResultsDidSelectIndex(_ index: Int)
}

final class SearchResultsView: NSView {
    weak var delegate: SearchResultsViewDelegate?

    private var results: [ActionableElement] = []
    private var selectedIndex = 0

    private let searchField: NSTextField = {
        let field = NSTextField()
        field.placeholderString = "Search all UI elements..."
        field.font = NSFont.systemFont(ofSize: 20)
        field.isBezeled = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let scrollView: NSScrollView = {
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private let tableView: NSTableView = {
        let table = NSTableView()
        table.headerView = nil
        table.rowHeight = 40
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("results"))
        column.width = 500
        table.addTableColumn(column)
        return table
    }()

    private let containerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        view.layer?.cornerRadius = 12
        view.layer?.shadowColor = NSColor.black.cgColor
        view.layer?.shadowOpacity = 0.4
        view.layer?.shadowRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        containerView.addSubview(searchField)
        containerView.addSubview(scrollView)

        scrollView.documentView = tableView
        tableView.dataSource = self
        tableView.delegate = self
        searchField.delegate = self

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 600),
            containerView.heightAnchor.constraint(equalToConstant: 400),

            searchField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }

    func updateResults(_ elements: [ActionableElement]) {
        results = Array(elements.prefix(50)) // Limit to 50 results
        selectedIndex = 0
        tableView.reloadData()
        if !results.isEmpty {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }

    func focus() {
        window?.makeFirstResponder(searchField)
    }
}

extension SearchResultsView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        results.count
    }
}

extension SearchResultsView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let element = results[row]

        let cell = NSTableCellView()
        let textField = NSTextField(labelWithString: "\(element.label) (\(element.role))")
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.translatesAutoresizingMaskIntoConstraints = false

        cell.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8),
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])

        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedIndex = tableView.selectedRow
        delegate?.searchResultsDidSelectIndex(selectedIndex)
    }
}

extension SearchResultsView: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        delegate?.searchResultsDidChangeQuery(searchField.stringValue)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            delegate?.searchResultsDidPressEscape()
            return true
        }
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            delegate?.searchResultsDidPressEnter()
            return true
        }
        if commandSelector == #selector(NSResponder.moveUp(_:)) {
            if selectedIndex > 0 {
                selectedIndex -= 1
                tableView.selectRowIndexes(IndexSet(integer: selectedIndex), byExtendingSelection: false)
                tableView.scrollRowToVisible(selectedIndex)
            }
            return true
        }
        if commandSelector == #selector(NSResponder.moveDown(_:)) {
            if selectedIndex < results.count - 1 {
                selectedIndex += 1
                tableView.selectRowIndexes(IndexSet(integer: selectedIndex), byExtendingSelection: false)
                tableView.scrollRowToVisible(selectedIndex)
            }
            return true
        }
        return false
    }
}
