// Sources/KeyNav/App/AppDelegate.swift
import AppKit
import Combine
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var onboardingWindow: NSWindow?
    private var preferencesWindowController: PreferencesWindowController?
    private var cancellables = Set<AnyCancellable>()
    private let updaterController: SPUStandardUpdaterController

    // Menu bar icon names
    private let normalIcon = "keyboard"
    private let errorIcon = "keyboard.badge.exclamationmark"

    override init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarItem()
        setupStatusObserver()
        setupNotificationObservers()
        NSApp.setActivationPolicy(.accessory)

        checkAccessibilityPermission()
    }

    // MARK: - Menu Bar

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: normalIcon, accessibilityDescription: "KeyNav")
        }

        updateMenu()
    }

    private func updateMenu() {
        let menu = NSMenu()

        // Status indicator
        let statusItem = NSMenuItem(title: getStatusTitle(), action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(NSMenuItem.separator())

        // Preferences
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ","))

        // Check for Updates
        let updateItem = NSMenuItem(title: "Check for Updates...", action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)), keyEquivalent: "")
        updateItem.target = updaterController
        menu.addItem(updateItem)

        // Troubleshoot (shown when there are issues)
        if AppStatus.shared.hasAnyFailure {
            let troubleshootItem = NSMenuItem(title: "Troubleshoot...", action: #selector(openTroubleshoot), keyEquivalent: "")
            menu.addItem(troubleshootItem)
        }

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(title: "Quit KeyNav", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        self.statusItem?.menu = menu
    }

    private func getStatusTitle() -> String {
        if AppStatus.shared.isFullyOperational {
            return "Status: Active"
        } else if AppStatus.shared.hasAnyFailure {
            return "Status: Issues Detected"
        } else {
            return "Status: Starting..."
        }
    }

    private func updateMenuBarIcon() {
        guard let button = statusItem?.button else { return }

        if AppStatus.shared.hasAnyFailure {
            button.image = NSImage(systemSymbolName: errorIcon, accessibilityDescription: "KeyNav - Issues")
        } else {
            button.image = NSImage(systemSymbolName: normalIcon, accessibilityDescription: "KeyNav")
        }
    }

    // MARK: - Status Observer

    private func setupStatusObserver() {
        // Observe status changes
        AppStatus.shared.onStatusChange = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateMenuBarIcon()
                self?.updateMenu()
            }
        }

        // Handle critical failures
        AppStatus.shared.onCriticalFailure = { [weak self] title, message in
            self?.showErrorAlert(title: title, message: message)
        }
    }

    // MARK: - Notification Observers

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenPreferences),
            name: .openPreferences,
            object: nil
        )
    }

    @objc private func handleOpenPreferences() {
        openPreferences()
    }

    // MARK: - Permission Check

    private func checkAccessibilityPermission() {
        if PermissionManager.shared.isAccessibilityEnabled {
            startApp()
        } else {
            showOnboarding()
        }
    }

    private func showOnboarding() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 250),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "KeyNav Setup"
        window.center()

        let view = NSView(frame: window.contentView!.bounds)

        // Icon
        let iconView = NSImageView(frame: NSRect(x: 175, y: 170, width: 100, height: 60))
        iconView.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)
        iconView.contentTintColor = .controlAccentColor
        view.addSubview(iconView)

        // Title
        let titleLabel = NSTextField(labelWithString: "KeyNav needs Accessibility permission")
        titleLabel.frame = NSRect(x: 20, y: 130, width: 410, height: 30)
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.alignment = .center
        view.addSubview(titleLabel)

        // Description
        let label = NSTextField(labelWithString: "This allows KeyNav to detect and click UI elements using keyboard shortcuts.")
        label.frame = NSRect(x: 20, y: 85, width: 410, height: 40)
        label.alignment = .center
        label.lineBreakMode = .byWordWrapping
        view.addSubview(label)

        // Open Settings button
        let button = NSButton(title: "Open System Settings", target: self, action: #selector(openAccessibilityPreferences))
        button.frame = NSRect(x: 125, y: 35, width: 200, height: 40)
        button.bezelStyle = .rounded
        button.keyEquivalent = "\r"
        view.addSubview(button)

        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        onboardingWindow = window

        // Poll for permission with timeout
        PermissionManager.shared.pollForPermission(
            interval: 1.0,
            timeout: 120.0,  // 2 minutes
            onGranted: { [weak self] in
                self?.onboardingWindow?.close()
                self?.onboardingWindow = nil
                self?.startApp()
            },
            onTimeout: { [weak self] in
                self?.showPermissionTimeoutAlert()
            }
        )
    }

    @objc private func openAccessibilityPreferences() {
        PermissionManager.shared.openAccessibilityPreferences()
    }

    private func showPermissionTimeoutAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "Permission Not Granted"
            alert.informativeText = "KeyNav is still waiting for Accessibility permission. The app will continue to check for permission in the background.\n\nWould you like to try opening System Settings again?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Keep Waiting")
            alert.addButton(withTitle: "Quit")

            let response = alert.runModal()

            switch response {
            case .alertFirstButtonReturn:
                PermissionManager.shared.openAccessibilityPreferences()
                // Restart polling
                PermissionManager.shared.pollForPermission(
                    interval: 1.0,
                    timeout: 120.0,
                    onGranted: { [weak self] in
                        self?.onboardingWindow?.close()
                        self?.onboardingWindow = nil
                        self?.startApp()
                    },
                    onTimeout: { [weak self] in
                        self?.showPermissionTimeoutAlert()
                    }
                )
            case .alertSecondButtonReturn:
                // Continue polling without timeout
                PermissionManager.shared.pollForPermission(
                    interval: 1.0,
                    timeout: nil,
                    onGranted: { [weak self] in
                        self?.onboardingWindow?.close()
                        self?.onboardingWindow = nil
                        self?.startApp()
                    },
                    onTimeout: nil
                )
            case .alertThirdButtonReturn:
                NSApp.terminate(nil)
            default:
                break
            }
        }
    }

    // MARK: - Start App

    private func startApp() {
        // Configure error callbacks before setup
        Coordinator.shared.onSetupFailed = { [weak self] message in
            DispatchQueue.main.async {
                self?.showStartupErrorAlert(message: message)
            }
        }

        Coordinator.shared.setup()

        // Show startup status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.checkStartupStatus()
        }
    }

    private func checkStartupStatus() {
        if AppStatus.shared.hasAnyFailure {
            // Show a non-blocking notification about issues
            showStatusNotification()
        }
    }

    private func showStatusNotification() {
        // Update the menu to show troubleshoot option
        updateMenu()
        updateMenuBarIcon()
    }

    // MARK: - Error Alerts

    private func showErrorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open Preferences")
            alert.addButton(withTitle: "Dismiss")

            let response = alert.runModal()

            if response == .alertFirstButtonReturn {
                self.openPreferences()
            }
        }
    }

    private func showStartupErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "KeyNav Startup Issue"
        alert.informativeText = "Some features may not work correctly:\n\n\(message)\n\nYou can try to fix these issues in Preferences."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Preferences")
        alert.addButton(withTitle: "Continue Anyway")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            openPreferences()
        }
    }

    // MARK: - Preferences

    @objc private func openPreferences() {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
        }
        preferencesWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Troubleshoot

    @objc private func openTroubleshoot() {
        // Open preferences to the diagnostic tab
        openPreferences()
        preferencesWindowController?.showDiagnosticTab()
    }
}
