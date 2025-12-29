// Sources/KeyNav/App/AppDelegate.swift
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var onboardingWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarItem()
        NSApp.setActivationPolicy(.accessory)

        checkAccessibilityPermission()
    }

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "KeyNav")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit KeyNav", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    private func checkAccessibilityPermission() {
        if PermissionManager.shared.isAccessibilityEnabled {
            startApp()
        } else {
            showOnboarding()
        }
    }

    private func showOnboarding() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "KeyNav Setup"
        window.center()

        let view = NSView(frame: window.contentView!.bounds)

        let label = NSTextField(labelWithString: "KeyNav needs Accessibility permission to detect and click UI elements.")
        label.frame = NSRect(x: 20, y: 120, width: 360, height: 60)
        label.alignment = .center
        label.lineBreakMode = .byWordWrapping
        view.addSubview(label)

        let button = NSButton(title: "Open System Preferences", target: self, action: #selector(openAccessibilityPreferences))
        button.frame = NSRect(x: 100, y: 50, width: 200, height: 40)
        button.bezelStyle = .rounded
        view.addSubview(button)

        window.contentView = view
        window.makeKeyAndOrderFront(nil)

        onboardingWindow = window

        // Poll for permission
        PermissionManager.shared.pollForPermission { [weak self] granted in
            if granted {
                self?.onboardingWindow?.close()
                self?.onboardingWindow = nil
                self?.startApp()
            }
        }
    }

    @objc private func openAccessibilityPreferences() {
        PermissionManager.shared.openAccessibilityPreferences()
    }

    private func startApp() {
        Coordinator.shared.setup()
    }

    @objc private func openPreferences() {
        // TODO: Open preferences window
    }
}
