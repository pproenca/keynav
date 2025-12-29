// Sources/KeyNav/Core/HotkeyManager.swift
import AppKit
import HotKey
import Carbon

final class HotkeyManager {
    static let shared = HotkeyManager()

    private var hintModeHotkey: HotKey?
    private var scrollModeHotkey: HotKey?
    private var searchModeHotkey: HotKey?

    var onHintModeActivated: (() -> Void)?
    var onScrollModeActivated: (() -> Void)?
    var onSearchModeActivated: (() -> Void)?

    private init() {}

    func setup() {
        setupHintModeHotkey()
        setupScrollModeHotkey()
        setupSearchModeHotkey()
    }

    private func setupHintModeHotkey() {
        // Cmd + Shift + Space
        hintModeHotkey = HotKey(key: .space, modifiers: [.command, .shift])
        hintModeHotkey?.keyDownHandler = { [weak self] in
            self?.onHintModeActivated?()
        }
    }

    private func setupScrollModeHotkey() {
        // Cmd + Shift + J
        scrollModeHotkey = HotKey(key: .j, modifiers: [.command, .shift])
        scrollModeHotkey?.keyDownHandler = { [weak self] in
            self?.onScrollModeActivated?()
        }
    }

    private func setupSearchModeHotkey() {
        // Cmd + Shift + /
        searchModeHotkey = HotKey(key: .slash, modifiers: [.command, .shift])
        searchModeHotkey?.keyDownHandler = { [weak self] in
            self?.onSearchModeActivated?()
        }
    }

    func updateHintModeHotkey(key: Key, modifiers: NSEvent.ModifierFlags) {
        hintModeHotkey = HotKey(key: key, modifiers: modifiers)
        hintModeHotkey?.keyDownHandler = { [weak self] in
            self?.onHintModeActivated?()
        }
    }

    func updateScrollModeHotkey(key: Key, modifiers: NSEvent.ModifierFlags) {
        scrollModeHotkey = HotKey(key: key, modifiers: modifiers)
        scrollModeHotkey?.keyDownHandler = { [weak self] in
            self?.onScrollModeActivated?()
        }
    }

    func updateSearchModeHotkey(key: Key, modifiers: NSEvent.ModifierFlags) {
        searchModeHotkey = HotKey(key: key, modifiers: modifiers)
        searchModeHotkey?.keyDownHandler = { [weak self] in
            self?.onSearchModeActivated?()
        }
    }

    func disable() {
        hintModeHotkey = nil
        scrollModeHotkey = nil
        searchModeHotkey = nil
    }
}
