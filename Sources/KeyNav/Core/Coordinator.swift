// Sources/KeyNav/Core/Coordinator.swift
import AppKit

final class Coordinator {
    static let shared = Coordinator()

    private let hintMode = HintMode()
    private let scrollMode = ScrollMode()
    private let searchMode = SearchMode()

    private var currentMode: Mode?
    private var eventMonitor: Any?

    private init() {
        hintMode.delegate = self
        scrollMode.delegate = self
        searchMode.delegate = self
    }

    func setup() {
        HotkeyManager.shared.onHintModeActivated = { [weak self] in
            self?.activateMode(.hint)
        }
        HotkeyManager.shared.onScrollModeActivated = { [weak self] in
            self?.activateMode(.scroll)
        }
        HotkeyManager.shared.onSearchModeActivated = { [weak self] in
            self?.activateMode(.search)
        }
        HotkeyManager.shared.setup()
    }

    func activateMode(_ type: ModeType) {
        // Deactivate current mode if different
        if let current = currentMode, current.type != type {
            current.deactivate()
        }

        let mode: Mode
        switch type {
        case .hint:
            mode = hintMode
        case .scroll:
            mode = scrollMode
        case .search:
            mode = searchMode
        case .normal:
            // Normal mode has no special behavior, just deactivate
            deactivateCurrentMode()
            return
        }

        currentMode = mode
        mode.activate()
        startEventMonitor()
    }

    func deactivateCurrentMode() {
        currentMode?.deactivate()
        currentMode = nil
        stopEventMonitor()
    }

    private func startEventMonitor() {
        stopEventMonitor()

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, let mode = self.currentMode else { return event }

            if mode.handleKeyDown(event) {
                return nil // Event handled
            }
            return event
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

extension Coordinator: HintModeDelegate {
    func hintModeDidDeactivate() {
        currentMode = nil
        stopEventMonitor()
    }

    func hintModeDidSelectElement(_ element: ActionableElement, clickType: ClickType) {
        // Could log or trigger custom actions based on click type
    }
}

extension Coordinator: ScrollModeDelegate {
    func scrollModeDidDeactivate() {
        currentMode = nil
        stopEventMonitor()
    }
}

extension Coordinator: SearchModeDelegate {
    func searchModeDidDeactivate() {
        currentMode = nil
        stopEventMonitor()
    }

    func searchModeDidSelectElement(_ element: ActionableElement) {
        // Could log or trigger custom actions
    }
}
