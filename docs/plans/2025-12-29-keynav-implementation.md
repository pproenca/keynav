# KeyNav Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build KeyNav, a free open-source Homerow alternative for macOS keyboard-driven GUI navigation.

**Architecture:** Swift app using macOS Accessibility API (AXUIElement) to detect clickable elements, overlay windows for hint rendering, and global hotkeys for activation. Four modes: hint, scroll, search, and custom shortcuts.

**Tech Stack:** Swift 5.9+, AppKit, XCTest, Swift Package Manager (Sparkle, HotKey, LaunchAtLogin)

---

## Phase 1: Project Setup

### Task 1.1: Create Xcode Project

**Files:**
- Create: `KeyNav/` (Xcode project structure)

**Step 1: Create the Xcode project using command line**

```bash
cd /Users/pedroproenca/Documents/Projects/macvim
mkdir -p KeyNav
cd KeyNav
swift package init --type executable --name KeyNav
```

**Step 2: Create the Xcode project file**

We'll use a Package.swift for SPM-based macOS app:

```swift
// Package.swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KeyNav",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "KeyNav", targets: ["KeyNav"])
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.2.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin-Modern.git", from: "1.0.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "KeyNav",
            dependencies: [
                "HotKey",
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin-Modern"),
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/KeyNav"
        ),
        .testTarget(
            name: "KeyNavTests",
            dependencies: ["KeyNav"],
            path: "Tests/KeyNavTests"
        )
    ]
)
```

**Step 3: Create directory structure**

```bash
mkdir -p Sources/KeyNav/App
mkdir -p Sources/KeyNav/Core/Modes
mkdir -p Sources/KeyNav/Accessibility
mkdir -p Sources/KeyNav/UI/Settings
mkdir -p Sources/KeyNav/Shortcuts
mkdir -p Sources/KeyNav/Utilities
mkdir -p Sources/KeyNav/Resources
mkdir -p Tests/KeyNavTests
```

**Step 4: Verify structure**

```bash
find Sources Tests -type d
```

Expected: All directories created.

**Step 5: Commit**

```bash
git add .
git commit -m "chore: initialize KeyNav Swift package with dependencies"
```

---

### Task 1.2: Create App Entry Point

**Files:**
- Create: `Sources/KeyNav/App/KeyNavApp.swift`
- Create: `Sources/KeyNav/App/AppDelegate.swift`
- Create: `Sources/KeyNav/main.swift`

**Step 1: Write main.swift**

```swift
// Sources/KeyNav/main.swift
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

**Step 2: Write AppDelegate.swift**

```swift
// Sources/KeyNav/App/AppDelegate.swift
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarItem()
        NSApp.setActivationPolicy(.accessory)
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

    @objc private func openPreferences() {
        // TODO: Open preferences window
    }
}
```

**Step 3: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 4: Commit**

```bash
git add .
git commit -m "feat: add app entry point with menu bar item"
```

---

### Task 1.3: Create Info.plist for macOS App

**Files:**
- Create: `Sources/KeyNav/Resources/Info.plist`

**Step 1: Write Info.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>KeyNav</string>
    <key>CFBundleIdentifier</key>
    <string>com.keynav.app</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAccessibilityUsageDescription</key>
    <string>KeyNav needs accessibility access to detect and click UI elements across all applications.</string>
</dict>
</plist>
```

**Step 2: Commit**

```bash
git add .
git commit -m "chore: add Info.plist with accessibility usage description"
```

---

## Phase 2: Accessibility Engine

### Task 2.1: Create ActionableElement Model

**Files:**
- Create: `Sources/KeyNav/Accessibility/ActionableElement.swift`
- Create: `Tests/KeyNavTests/ActionableElementTests.swift`

**Step 1: Write the test**

```swift
// Tests/KeyNavTests/ActionableElementTests.swift
import XCTest
@testable import KeyNav

final class ActionableElementTests: XCTestCase {

    func testActionableElementInitialization() {
        let frame = CGRect(x: 100, y: 200, width: 50, height: 30)
        let element = ActionableElement(
            role: "AXButton",
            label: "Submit",
            frame: frame,
            actions: ["AXPress"],
            identifier: "submit-btn"
        )

        XCTAssertEqual(element.role, "AXButton")
        XCTAssertEqual(element.label, "Submit")
        XCTAssertEqual(element.frame, frame)
        XCTAssertEqual(element.actions, ["AXPress"])
        XCTAssertEqual(element.identifier, "submit-btn")
    }

    func testIsClickable() {
        let clickable = ActionableElement(
            role: "AXButton",
            label: "OK",
            frame: .zero,
            actions: ["AXPress"],
            identifier: nil
        )
        XCTAssertTrue(clickable.isClickable)

        let notClickable = ActionableElement(
            role: "AXStaticText",
            label: "Label",
            frame: .zero,
            actions: [],
            identifier: nil
        )
        XCTAssertFalse(notClickable.isClickable)
    }
}
```

**Step 2: Run test to verify it fails**

```bash
swift test --filter ActionableElementTests
```

Expected: FAIL - module/type not found.

**Step 3: Write ActionableElement**

```swift
// Sources/KeyNav/Accessibility/ActionableElement.swift
import Foundation
import ApplicationServices

struct ActionableElement: Equatable {
    let axElement: AXUIElement?
    let role: String
    let label: String
    let frame: CGRect
    let actions: [String]
    let identifier: String?

    init(
        axElement: AXUIElement? = nil,
        role: String,
        label: String,
        frame: CGRect,
        actions: [String],
        identifier: String?
    ) {
        self.axElement = axElement
        self.role = role
        self.label = label
        self.frame = frame
        self.actions = actions
        self.identifier = identifier
    }

    var isClickable: Bool {
        let clickableActions = ["AXPress", "AXConfirm", "AXOpen", "AXPick"]
        return actions.contains { clickableActions.contains($0) }
    }

    var isScrollable: Bool {
        role == "AXScrollArea" || role == "AXScrollBar"
    }

    static func == (lhs: ActionableElement, rhs: ActionableElement) -> Bool {
        lhs.role == rhs.role &&
        lhs.label == rhs.label &&
        lhs.frame == rhs.frame &&
        lhs.actions == rhs.actions &&
        lhs.identifier == rhs.identifier
    }
}
```

**Step 4: Run test to verify it passes**

```bash
swift test --filter ActionableElementTests
```

Expected: PASS

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add ActionableElement model with clickable detection"
```

---

### Task 2.2: Create PermissionManager

**Files:**
- Create: `Sources/KeyNav/Accessibility/PermissionManager.swift`

**Step 1: Write PermissionManager**

```swift
// Sources/KeyNav/Accessibility/PermissionManager.swift
import AppKit
import ApplicationServices

final class PermissionManager {
    static let shared = PermissionManager()

    private init() {}

    var isAccessibilityEnabled: Bool {
        AXIsProcessTrusted()
    }

    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    func pollForPermission(interval: TimeInterval = 1.0, completion: @escaping (Bool) -> Void) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.isAccessibilityEnabled {
                timer.invalidate()
                completion(true)
            }
        }
    }
}
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add PermissionManager for accessibility permission handling"
```

---

### Task 2.3: Create Element Traversal

**Files:**
- Create: `Sources/KeyNav/Accessibility/ElementTraversal.swift`
- Create: `Tests/KeyNavTests/ElementTraversalTests.swift`

**Step 1: Write test for attribute extraction helper**

```swift
// Tests/KeyNavTests/ElementTraversalTests.swift
import XCTest
@testable import KeyNav

final class ElementTraversalTests: XCTestCase {

    func testClickableRoles() {
        let traversal = ElementTraversal()

        XCTAssertTrue(traversal.isClickableRole("AXButton"))
        XCTAssertTrue(traversal.isClickableRole("AXLink"))
        XCTAssertTrue(traversal.isClickableRole("AXCheckBox"))
        XCTAssertTrue(traversal.isClickableRole("AXMenuItem"))
        XCTAssertFalse(traversal.isClickableRole("AXStaticText"))
        XCTAssertFalse(traversal.isClickableRole("AXGroup"))
    }
}
```

**Step 2: Run test to verify it fails**

```bash
swift test --filter ElementTraversalTests
```

Expected: FAIL

**Step 3: Write ElementTraversal**

```swift
// Sources/KeyNav/Accessibility/ElementTraversal.swift
import ApplicationServices
import Foundation

final class ElementTraversal {

    private let clickableRoles: Set<String> = [
        "AXButton",
        "AXLink",
        "AXCheckBox",
        "AXRadioButton",
        "AXMenuItem",
        "AXMenuBarItem",
        "AXCell",
        "AXPopUpButton",
        "AXComboBox",
        "AXTextField",
        "AXTextArea",
        "AXSlider",
        "AXIncrementor",
        "AXColorWell",
        "AXToolbarButton",
        "AXTab",
        "AXTabGroup"
    ]

    func isClickableRole(_ role: String) -> Bool {
        clickableRoles.contains(role)
    }

    func getFrontmostApplication() -> AXUIElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        return AXUIElementCreateApplication(app.processIdentifier)
    }

    func getFocusedWindow(from app: AXUIElement) -> AXUIElement? {
        var windowRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute as CFString, &windowRef)
        guard result == .success else { return nil }
        return (windowRef as! AXUIElement)
    }

    func getChildren(of element: AXUIElement) -> [AXUIElement] {
        var childrenRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenRef)
        guard result == .success, let children = childrenRef as? [AXUIElement] else { return [] }
        return children
    }

    func getRole(of element: AXUIElement) -> String? {
        var roleRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef)
        guard result == .success else { return nil }
        return roleRef as? String
    }

    func getLabel(of element: AXUIElement) -> String {
        // Try AXTitle first
        var titleRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &titleRef) == .success,
           let title = titleRef as? String, !title.isEmpty {
            return title
        }

        // Try AXDescription
        var descRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXDescriptionAttribute as CFString, &descRef) == .success,
           let desc = descRef as? String, !desc.isEmpty {
            return desc
        }

        // Try AXValue
        var valueRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueRef) == .success,
           let value = valueRef as? String, !value.isEmpty {
            return value
        }

        return ""
    }

    func getFrame(of element: AXUIElement) -> CGRect? {
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?

        guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionRef) == .success,
              AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeRef) == .success else {
            return nil
        }

        var position = CGPoint.zero
        var size = CGSize.zero

        AXValueGetValue(positionRef as! AXValue, .cgPoint, &position)
        AXValueGetValue(sizeRef as! AXValue, .cgSize, &size)

        return CGRect(origin: position, size: size)
    }

    func getActions(of element: AXUIElement) -> [String] {
        var actionsRef: CFArray?
        let result = AXUIElementCopyActionNames(element, &actionsRef)
        guard result == .success, let actions = actionsRef as? [String] else { return [] }
        return actions
    }

    func getIdentifier(of element: AXUIElement) -> String? {
        var identifierRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXIdentifierAttribute as CFString, &identifierRef)
        guard result == .success else { return nil }
        return identifierRef as? String
    }

    func isEnabled(element: AXUIElement) -> Bool {
        var enabledRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXEnabledAttribute as CFString, &enabledRef)
        guard result == .success else { return true } // Assume enabled if attribute missing
        return (enabledRef as? Bool) ?? true
    }

    func traverseElements(
        from element: AXUIElement,
        maxDepth: Int = 20,
        currentDepth: Int = 0
    ) -> [ActionableElement] {
        guard currentDepth < maxDepth else { return [] }

        var results: [ActionableElement] = []

        // Check if this element is actionable
        if let role = getRole(of: element),
           let frame = getFrame(of: element),
           frame.width > 0, frame.height > 0,
           isEnabled(element: element) {

            let actions = getActions(of: element)
            let label = getLabel(of: element)
            let identifier = getIdentifier(of: element)

            let isClickable = !actions.isEmpty || isClickableRole(role)

            if isClickable && !label.isEmpty {
                let actionable = ActionableElement(
                    axElement: element,
                    role: role,
                    label: label,
                    frame: frame,
                    actions: actions,
                    identifier: identifier
                )
                results.append(actionable)
            }
        }

        // Traverse children
        let children = getChildren(of: element)
        for child in children {
            results.append(contentsOf: traverseElements(
                from: child,
                maxDepth: maxDepth,
                currentDepth: currentDepth + 1
            ))
        }

        return results
    }
}
```

**Step 4: Run test to verify it passes**

```bash
swift test --filter ElementTraversalTests
```

Expected: PASS

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add ElementTraversal for AXUIElement tree traversal"
```

---

### Task 2.4: Create AccessibilityEngine

**Files:**
- Create: `Sources/KeyNav/Accessibility/AccessibilityEngine.swift`

**Step 1: Write AccessibilityEngine**

```swift
// Sources/KeyNav/Accessibility/AccessibilityEngine.swift
import ApplicationServices
import Foundation

final class AccessibilityEngine {
    private let traversal = ElementTraversal()
    private let queue = DispatchQueue(label: "com.keynav.accessibility", qos: .userInteractive)

    func getActionableElements(completion: @escaping ([ActionableElement]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            let elements = self.getActionableElementsSync()
            DispatchQueue.main.async { completion(elements) }
        }
    }

    func getActionableElementsSync() -> [ActionableElement] {
        guard PermissionManager.shared.isAccessibilityEnabled else { return [] }
        guard let app = traversal.getFrontmostApplication() else { return [] }
        guard let window = traversal.getFocusedWindow(from: app) else { return [] }

        return traversal.traverseElements(from: window)
    }

    func getAllWindowElements(completion: @escaping ([ActionableElement]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            var allElements: [ActionableElement] = []

            let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }

            for app in runningApps {
                let axApp = AXUIElementCreateApplication(app.processIdentifier)

                var windowsRef: CFTypeRef?
                guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef) == .success,
                      let windows = windowsRef as? [AXUIElement] else { continue }

                for window in windows {
                    let elements = self.traversal.traverseElements(from: window)
                    allElements.append(contentsOf: elements)
                }
            }

            DispatchQueue.main.async { completion(allElements) }
        }
    }

    func performClick(on element: ActionableElement) {
        guard let axElement = element.axElement else { return }

        if element.actions.contains("AXPress") {
            AXUIElementPerformAction(axElement, kAXPressAction as CFString)
        } else if element.actions.contains("AXConfirm") {
            AXUIElementPerformAction(axElement, kAXConfirmAction as CFString)
        } else {
            // Fallback: simulate mouse click at element center
            let center = CGPoint(
                x: element.frame.midX,
                y: element.frame.midY
            )
            simulateClick(at: center)
        }
    }

    func performDoubleClick(on element: ActionableElement) {
        let center = CGPoint(x: element.frame.midX, y: element.frame.midY)
        simulateClick(at: center, clickCount: 2)
    }

    func performRightClick(on element: ActionableElement) {
        let center = CGPoint(x: element.frame.midX, y: element.frame.midY)
        simulateRightClick(at: center)
    }

    private func simulateClick(at point: CGPoint, clickCount: Int = 1) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)

        mouseDown?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))
        mouseUp?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }

    private func simulateRightClick(at point: CGPoint) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: point, mouseButton: .right)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: point, mouseButton: .right)

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
}
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add AccessibilityEngine for element detection and clicking"
```

---

## Phase 3: Hint Generation

### Task 3.1: Create HintLabelGenerator

**Files:**
- Create: `Sources/KeyNav/Utilities/HintLabelGenerator.swift`
- Create: `Tests/KeyNavTests/HintLabelGeneratorTests.swift`

**Step 1: Write tests**

```swift
// Tests/KeyNavTests/HintLabelGeneratorTests.swift
import XCTest
@testable import KeyNav

final class HintLabelGeneratorTests: XCTestCase {

    func testGenerateSingleCharHints() {
        let generator = HintLabelGenerator()
        let hints = generator.generate(count: 5)

        XCTAssertEqual(hints.count, 5)
        XCTAssertEqual(hints[0], "A")
        XCTAssertEqual(hints[1], "S")
        XCTAssertEqual(hints[2], "D")
        XCTAssertEqual(hints[3], "F")
        XCTAssertEqual(hints[4], "G")
    }

    func testGenerateTwoCharHints() {
        let generator = HintLabelGenerator()
        let hints = generator.generate(count: 20)

        XCTAssertEqual(hints.count, 20)
        // First 16 are single chars
        XCTAssertEqual(hints[0], "A")
        XCTAssertEqual(hints[15], "O")
        // Then two-char combos
        XCTAssertEqual(hints[16], "AA")
        XCTAssertEqual(hints[17], "AS")
    }

    func testGenerateEmpty() {
        let generator = HintLabelGenerator()
        let hints = generator.generate(count: 0)

        XCTAssertEqual(hints.count, 0)
    }

    func testAllHintsUnique() {
        let generator = HintLabelGenerator()
        let hints = generator.generate(count: 100)
        let uniqueHints = Set(hints)

        XCTAssertEqual(hints.count, uniqueHints.count)
    }
}
```

**Step 2: Run test to verify it fails**

```bash
swift test --filter HintLabelGeneratorTests
```

Expected: FAIL

**Step 3: Write HintLabelGenerator**

```swift
// Sources/KeyNav/Utilities/HintLabelGenerator.swift
import Foundation

struct HintLabelGenerator {
    private let hintChars = Array("ASDFGHJKLQWERUIO")

    func generate(count: Int) -> [String] {
        guard count > 0 else { return [] }

        var hints: [String] = []

        // First pass: single chars
        for char in hintChars.prefix(min(count, hintChars.count)) {
            hints.append(String(char))
        }

        // Second pass: two-char combos if needed
        if count > hintChars.count {
            outer: for first in hintChars {
                for second in hintChars {
                    hints.append("\(first)\(second)")
                    if hints.count >= count { break outer }
                }
            }
        }

        return Array(hints.prefix(count))
    }
}
```

**Step 4: Run test to verify it passes**

```bash
swift test --filter HintLabelGeneratorTests
```

Expected: PASS

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add HintLabelGenerator for creating hint labels"
```

---

### Task 3.2: Create FuzzyMatcher

**Files:**
- Create: `Sources/KeyNav/Utilities/FuzzyMatcher.swift`
- Create: `Tests/KeyNavTests/FuzzyMatcherTests.swift`

**Step 1: Write tests**

```swift
// Tests/KeyNavTests/FuzzyMatcherTests.swift
import XCTest
@testable import KeyNav

final class FuzzyMatcherTests: XCTestCase {

    func testExactMatch() {
        let matcher = FuzzyMatcher()
        XCTAssertTrue(matcher.matches(query: "Save", in: "Save"))
    }

    func testCaseInsensitiveMatch() {
        let matcher = FuzzyMatcher()
        XCTAssertTrue(matcher.matches(query: "save", in: "Save Document"))
    }

    func testSubstringMatch() {
        let matcher = FuzzyMatcher()
        XCTAssertTrue(matcher.matches(query: "doc", in: "Save Document"))
    }

    func testNoMatch() {
        let matcher = FuzzyMatcher()
        XCTAssertFalse(matcher.matches(query: "xyz", in: "Save Document"))
    }

    func testEmptyQuery() {
        let matcher = FuzzyMatcher()
        XCTAssertTrue(matcher.matches(query: "", in: "Anything"))
    }

    func testMatchRange() {
        let matcher = FuzzyMatcher()
        let range = matcher.matchRange(query: "Doc", in: "Save Document")

        XCTAssertNotNil(range)
        XCTAssertEqual(range?.lowerBound, "Save Document".index("Save Document".startIndex, offsetBy: 5))
    }

    func testFilterElements() {
        let matcher = FuzzyMatcher()
        let elements = [
            ActionableElement(role: "AXButton", label: "Save", frame: .zero, actions: ["AXPress"], identifier: nil),
            ActionableElement(role: "AXButton", label: "Open", frame: .zero, actions: ["AXPress"], identifier: nil),
            ActionableElement(role: "AXButton", label: "Save As", frame: .zero, actions: ["AXPress"], identifier: nil)
        ]

        let filtered = matcher.filter(elements: elements, query: "save")

        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered[0].label, "Save")
        XCTAssertEqual(filtered[1].label, "Save As")
    }
}
```

**Step 2: Run test to verify it fails**

```bash
swift test --filter FuzzyMatcherTests
```

Expected: FAIL

**Step 3: Write FuzzyMatcher**

```swift
// Sources/KeyNav/Utilities/FuzzyMatcher.swift
import Foundation

struct FuzzyMatcher {

    func matches(query: String, in text: String) -> Bool {
        guard !query.isEmpty else { return true }
        return text.localizedCaseInsensitiveContains(query)
    }

    func matchRange(query: String, in text: String) -> Range<String.Index>? {
        guard !query.isEmpty else { return nil }
        return text.range(of: query, options: .caseInsensitive)
    }

    func filter(elements: [ActionableElement], query: String) -> [ActionableElement] {
        guard !query.isEmpty else { return elements }

        return elements.filter { matches(query: query, in: $0.label) }
    }

    func score(query: String, in text: String) -> Int {
        guard matches(query: query, in: text) else { return 0 }

        let lowercaseText = text.lowercased()
        let lowercaseQuery = query.lowercased()

        // Exact match gets highest score
        if lowercaseText == lowercaseQuery { return 100 }

        // Starts with query gets high score
        if lowercaseText.hasPrefix(lowercaseQuery) { return 80 }

        // Contains query gets medium score
        return 50
    }

    func filterAndSort(elements: [ActionableElement], query: String) -> [ActionableElement] {
        guard !query.isEmpty else { return elements }

        return elements
            .map { ($0, score(query: query, in: $0.label)) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}
```

**Step 4: Run test to verify it passes**

```bash
swift test --filter FuzzyMatcherTests
```

Expected: PASS

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add FuzzyMatcher for search-based element filtering"
```

---

## Phase 4: Overlay Window

### Task 4.1: Create OverlayWindow

**Files:**
- Create: `Sources/KeyNav/UI/OverlayWindow.swift`

**Step 1: Write OverlayWindow**

```swift
// Sources/KeyNav/UI/OverlayWindow.swift
import AppKit

final class OverlayWindow: NSWindow {

    init() {
        let screenFrame = NSScreen.main?.frame ?? .zero

        super.init(
            contentRect: screenFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        self.level = .screenSaver
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    func show() {
        // Update frame to current screen size
        if let screenFrame = NSScreen.main?.frame {
            setFrame(screenFrame, display: true)
        }
        orderFrontRegardless()
    }

    func dismiss() {
        orderOut(nil)
    }
}
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add OverlayWindow for transparent hint overlay"
```

---

### Task 4.2: Create HintView

**Files:**
- Create: `Sources/KeyNav/UI/HintView.swift`

**Step 1: Write HintView**

```swift
// Sources/KeyNav/UI/HintView.swift
import AppKit

struct HintViewModel {
    let label: String
    let frame: CGRect
    let matchedRange: Range<String.Index>?

    init(label: String, frame: CGRect, matchedRange: Range<String.Index>? = nil) {
        self.label = label
        self.frame = frame
        self.matchedRange = matchedRange
    }
}

final class HintView: NSView {
    private var hints: [HintViewModel] = []

    var hintBackgroundColor: NSColor = NSColor.systemYellow
    var hintTextColor: NSColor = NSColor.black
    var hintFont: NSFont = NSFont.systemFont(ofSize: 12, weight: .bold)
    var hintCornerRadius: CGFloat = 3
    var hintPadding: CGFloat = 4

    func updateHints(_ hints: [HintViewModel]) {
        self.hints = hints
        needsDisplay = true
    }

    func clear() {
        hints = []
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        for hint in hints {
            drawHint(hint)
        }
    }

    private func drawHint(_ hint: HintViewModel) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: hintFont,
            .foregroundColor: hintTextColor
        ]

        let textSize = hint.label.size(withAttributes: attributes)

        let hintRect = CGRect(
            x: hint.frame.minX,
            y: bounds.height - hint.frame.minY - textSize.height - hintPadding * 2,
            width: textSize.width + hintPadding * 2,
            height: textSize.height + hintPadding * 2
        )

        // Draw background
        let backgroundPath = NSBezierPath(roundedRect: hintRect, xRadius: hintCornerRadius, yRadius: hintCornerRadius)

        // Shadow
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 3
        shadow.set()

        hintBackgroundColor.setFill()
        backgroundPath.fill()

        // Reset shadow
        NSShadow().set()

        // Draw text
        let textPoint = CGPoint(
            x: hintRect.minX + hintPadding,
            y: hintRect.minY + hintPadding
        )
        hint.label.draw(at: textPoint, withAttributes: attributes)
    }
}
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add HintView for rendering hint labels"
```

---

### Task 4.3: Create SearchBarView

**Files:**
- Create: `Sources/KeyNav/UI/SearchBarView.swift`

**Step 1: Write SearchBarView**

```swift
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
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add SearchBarView for search input"
```

---

## Phase 5: Hotkey Manager

### Task 5.1: Create HotkeyManager

**Files:**
- Create: `Sources/KeyNav/Core/HotkeyManager.swift`

**Step 1: Write HotkeyManager**

```swift
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
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add HotkeyManager for global hotkey registration"
```

---

## Phase 6: Core Modes

### Task 6.1: Create Mode Protocol and State

**Files:**
- Create: `Sources/KeyNav/Core/Modes/Mode.swift`

**Step 1: Write Mode protocol**

```swift
// Sources/KeyNav/Core/Modes/Mode.swift
import AppKit

enum ModeType {
    case hint
    case scroll
    case search
}

protocol Mode: AnyObject {
    var type: ModeType { get }
    var isActive: Bool { get }

    func activate()
    func deactivate()
    func handleKeyDown(_ event: NSEvent) -> Bool
}
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add Mode protocol for mode abstraction"
```

---

### Task 6.2: Create HintMode

**Files:**
- Create: `Sources/KeyNav/Core/Modes/HintMode.swift`

**Step 1: Write HintMode**

```swift
// Sources/KeyNav/Core/Modes/HintMode.swift
import AppKit

protocol HintModeDelegate: AnyObject {
    func hintModeDidDeactivate()
    func hintModeDidSelectElement(_ element: ActionableElement)
}

final class HintMode: Mode {
    let type: ModeType = .hint
    private(set) var isActive = false

    weak var delegate: HintModeDelegate?

    private let accessibilityEngine = AccessibilityEngine()
    private let hintGenerator = HintLabelGenerator()
    private let fuzzyMatcher = FuzzyMatcher()

    private var overlayWindow: OverlayWindow?
    private var hintView: HintView?
    private var searchBarView: SearchBarView?

    private var elements: [ActionableElement] = []
    private var filteredElements: [ActionableElement] = []
    private var hintLabels: [String] = []
    private var currentQuery = ""
    private var typedHintChars = ""

    func activate() {
        guard !isActive else { return }
        isActive = true

        setupOverlay()
        loadElements()
    }

    func deactivate() {
        guard isActive else { return }
        isActive = false

        overlayWindow?.dismiss()
        overlayWindow = nil
        hintView = nil
        searchBarView = nil
        elements = []
        filteredElements = []
        hintLabels = []
        currentQuery = ""
        typedHintChars = ""

        delegate?.hintModeDidDeactivate()
    }

    func handleKeyDown(_ event: NSEvent) -> Bool {
        guard isActive else { return false }

        // Escape to cancel
        if event.keyCode == 53 {
            deactivate()
            return true
        }

        // Backspace
        if event.keyCode == 51 {
            if !typedHintChars.isEmpty {
                typedHintChars.removeLast()
            } else if !currentQuery.isEmpty {
                currentQuery.removeLast()
                updateFilteredElements()
            }
            updateHints()
            return true
        }

        // Regular character
        if let chars = event.characters?.uppercased(), chars.count == 1 {
            let char = chars.first!

            // Check if this could be part of a hint
            if isHintChar(char) && !filteredElements.isEmpty {
                typedHintChars.append(char)

                // Check for hint match
                if let index = hintLabels.firstIndex(of: typedHintChars) {
                    let element = filteredElements[index]
                    selectElement(element)
                    return true
                }

                // Check if this could still match
                let possibleMatches = hintLabels.filter { $0.hasPrefix(typedHintChars) }
                if possibleMatches.isEmpty {
                    // Not a hint, treat as search query
                    typedHintChars = ""
                    currentQuery.append(Character(chars.lowercased()))
                    updateFilteredElements()
                }

                updateHints()
                return true
            } else {
                // Search character
                currentQuery.append(Character(chars.lowercased()))
                typedHintChars = ""
                updateFilteredElements()
                updateHints()
                return true
            }
        }

        return false
    }

    private func setupOverlay() {
        overlayWindow = OverlayWindow()

        let contentView = NSView(frame: overlayWindow!.frame)

        hintView = HintView(frame: contentView.bounds)
        hintView?.autoresizingMask = [.width, .height]
        contentView.addSubview(hintView!)

        searchBarView = SearchBarView(frame: CGRect(x: 0, y: contentView.bounds.height - 100, width: contentView.bounds.width, height: 100))
        searchBarView?.autoresizingMask = [.width, .minYMargin]
        searchBarView?.delegate = self
        contentView.addSubview(searchBarView!)

        overlayWindow?.contentView = contentView
        overlayWindow?.show()
        searchBarView?.focus()
    }

    private func loadElements() {
        accessibilityEngine.getActionableElements { [weak self] elements in
            self?.elements = elements
            self?.filteredElements = elements
            self?.updateHints()
        }
    }

    private func updateFilteredElements() {
        filteredElements = fuzzyMatcher.filterAndSort(elements: elements, query: currentQuery)
        typedHintChars = ""

        // Auto-select if single match
        if filteredElements.count == 1 && !currentQuery.isEmpty {
            selectElement(filteredElements[0])
        }
    }

    private func updateHints() {
        hintLabels = hintGenerator.generate(count: filteredElements.count)

        let hints = zip(filteredElements, hintLabels).map { element, label -> HintViewModel in
            let matchRange = fuzzyMatcher.matchRange(query: currentQuery, in: element.label)
            return HintViewModel(
                label: label,
                frame: element.frame,
                matchedRange: matchRange
            )
        }

        hintView?.updateHints(hints)
    }

    private func selectElement(_ element: ActionableElement) {
        deactivate()
        accessibilityEngine.performClick(on: element)
        delegate?.hintModeDidSelectElement(element)
    }

    private func isHintChar(_ char: Character) -> Bool {
        "ASDFGHJKLQWERUIO".contains(char)
    }
}

extension HintMode: SearchBarViewDelegate {
    func searchBarDidChangeText(_ text: String) {
        currentQuery = text.lowercased()
        typedHintChars = ""
        updateFilteredElements()
        updateHints()
    }

    func searchBarDidPressEscape() {
        deactivate()
    }

    func searchBarDidPressEnter() {
        if let first = filteredElements.first {
            selectElement(first)
        }
    }

    func searchBarDidPressArrowUp() {
        // Could implement selection cycling
    }

    func searchBarDidPressArrowDown() {
        // Could implement selection cycling
    }
}
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add HintMode for search-based click hints"
```

---

### Task 6.3: Create ScrollMode

**Files:**
- Create: `Sources/KeyNav/Core/Modes/ScrollMode.swift`

**Step 1: Write ScrollMode**

```swift
// Sources/KeyNav/Core/Modes/ScrollMode.swift
import AppKit

protocol ScrollModeDelegate: AnyObject {
    func scrollModeDidDeactivate()
}

final class ScrollMode: Mode {
    let type: ModeType = .scroll
    private(set) var isActive = false

    weak var delegate: ScrollModeDelegate?

    private var overlayWindow: OverlayWindow?
    private var scrollIndicatorView: NSView?
    private var currentScrollArea: CGRect?

    private let scrollAmount: CGFloat = 50
    private let pageScrollAmount: CGFloat = 300
    private var waitingForSecondG = false

    func activate() {
        guard !isActive else { return }
        isActive = true

        setupOverlay()
        findScrollableArea()
    }

    func deactivate() {
        guard isActive else { return }
        isActive = false

        overlayWindow?.dismiss()
        overlayWindow = nil
        scrollIndicatorView = nil
        currentScrollArea = nil
        waitingForSecondG = false

        delegate?.scrollModeDidDeactivate()
    }

    func handleKeyDown(_ event: NSEvent) -> Bool {
        guard isActive else { return false }

        let keyCode = event.keyCode

        // Escape to cancel
        if keyCode == 53 {
            deactivate()
            return true
        }

        guard let chars = event.charactersIgnoringModifiers?.lowercased() else { return false }

        switch chars {
        case "h":
            scroll(deltaX: scrollAmount, deltaY: 0)
            return true
        case "j":
            scroll(deltaX: 0, deltaY: -scrollAmount)
            return true
        case "k":
            scroll(deltaX: 0, deltaY: scrollAmount)
            return true
        case "l":
            scroll(deltaX: -scrollAmount, deltaY: 0)
            return true
        case "d":
            scroll(deltaX: 0, deltaY: -pageScrollAmount)
            return true
        case "u":
            scroll(deltaX: 0, deltaY: pageScrollAmount)
            return true
        case "g":
            if waitingForSecondG {
                scrollToTop()
                waitingForSecondG = false
            } else if event.modifierFlags.contains(.shift) {
                scrollToBottom()
            } else {
                waitingForSecondG = true
                // Reset after delay if no second g
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.waitingForSecondG = false
                }
            }
            return true
        default:
            waitingForSecondG = false
            return false
        }
    }

    private func setupOverlay() {
        overlayWindow = OverlayWindow()
        overlayWindow?.show()
    }

    private func findScrollableArea() {
        // For now, use the focused window bounds
        if let app = NSWorkspace.shared.frontmostApplication {
            let axApp = AXUIElementCreateApplication(app.processIdentifier)
            var windowRef: CFTypeRef?

            if AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &windowRef) == .success {
                let window = windowRef as! AXUIElement
                var positionRef: CFTypeRef?
                var sizeRef: CFTypeRef?

                if AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef) == .success,
                   AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef) == .success {

                    var position = CGPoint.zero
                    var size = CGSize.zero
                    AXValueGetValue(positionRef as! AXValue, .cgPoint, &position)
                    AXValueGetValue(sizeRef as! AXValue, .cgSize, &size)

                    currentScrollArea = CGRect(origin: position, size: size)
                    showScrollIndicator()
                }
            }
        }
    }

    private func showScrollIndicator() {
        guard let area = currentScrollArea, let window = overlayWindow else { return }

        let indicatorView = NSView(frame: .zero)
        indicatorView.wantsLayer = true
        indicatorView.layer?.borderColor = NSColor.systemRed.cgColor
        indicatorView.layer?.borderWidth = 3
        indicatorView.layer?.cornerRadius = 4

        // Convert to screen coordinates
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let flippedY = screenHeight - area.origin.y - area.height

        indicatorView.frame = CGRect(
            x: area.origin.x,
            y: flippedY,
            width: area.width,
            height: area.height
        )

        window.contentView?.addSubview(indicatorView)
        scrollIndicatorView = indicatorView
    }

    private func scroll(deltaX: CGFloat, deltaY: CGFloat) {
        guard let area = currentScrollArea else { return }

        let scrollPoint = CGPoint(x: area.midX, y: area.midY)

        let scrollEvent = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: Int32(deltaY),
            wheel2: Int32(deltaX),
            wheel3: 0
        )

        scrollEvent?.location = scrollPoint
        scrollEvent?.post(tap: .cghidEventTap)
    }

    private func scrollToTop() {
        // Send multiple large scroll ups
        for _ in 0..<10 {
            scroll(deltaX: 0, deltaY: 1000)
        }
    }

    private func scrollToBottom() {
        // Send multiple large scroll downs
        for _ in 0..<10 {
            scroll(deltaX: 0, deltaY: -1000)
        }
    }
}
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add ScrollMode for vim-style keyboard scrolling"
```

---

### Task 6.4: Create SearchMode

**Files:**
- Create: `Sources/KeyNav/Core/Modes/SearchMode.swift`

**Step 1: Write SearchMode**

```swift
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
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add SearchMode for spotlight-like UI search"
```

---

## Phase 7: Coordinator

### Task 7.1: Create Coordinator

**Files:**
- Create: `Sources/KeyNav/Core/Coordinator.swift`

**Step 1: Write Coordinator**

```swift
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

    func hintModeDidSelectElement(_ element: ActionableElement) {
        // Could log or trigger custom actions
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
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add Coordinator for mode orchestration"
```

---

### Task 7.2: Wire Up AppDelegate

**Files:**
- Modify: `Sources/KeyNav/App/AppDelegate.swift`

**Step 1: Update AppDelegate to use Coordinator**

```swift
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
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: wire up AppDelegate with Coordinator and onboarding"
```

---

## Phase 8: Custom Shortcuts

### Task 8.1: Create CustomShortcut Model

**Files:**
- Create: `Sources/KeyNav/Shortcuts/CustomShortcut.swift`
- Create: `Tests/KeyNavTests/CustomShortcutTests.swift`

**Step 1: Write tests**

```swift
// Tests/KeyNavTests/CustomShortcutTests.swift
import XCTest
@testable import KeyNav

final class CustomShortcutTests: XCTestCase {

    func testCustomShortcutCodable() throws {
        let shortcut = CustomShortcut(
            id: UUID(),
            name: "Reload Safari",
            hotkeyCode: 15,
            hotkeyModifiers: ["command", "option"],
            appBundleId: "com.apple.Safari",
            elementSignature: ElementSignature(
                identifier: "reload-button",
                label: "Reload",
                role: "AXButton",
                path: ["Window", "Toolbar", "Button"]
            ),
            action: .single
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(shortcut)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CustomShortcut.self, from: data)

        XCTAssertEqual(decoded.name, "Reload Safari")
        XCTAssertEqual(decoded.appBundleId, "com.apple.Safari")
        XCTAssertEqual(decoded.action, .single)
    }
}
```

**Step 2: Run test to verify it fails**

```bash
swift test --filter CustomShortcutTests
```

Expected: FAIL

**Step 3: Write CustomShortcut**

```swift
// Sources/KeyNav/Shortcuts/CustomShortcut.swift
import Foundation

enum ClickAction: String, Codable {
    case single
    case double
    case right
}

struct ElementSignature: Codable, Equatable {
    let identifier: String?
    let label: String
    let role: String
    let path: [String]
}

struct CustomShortcut: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var hotkeyCode: UInt16
    var hotkeyModifiers: [String]
    var appBundleId: String
    var elementSignature: ElementSignature
    var action: ClickAction

    static func == (lhs: CustomShortcut, rhs: CustomShortcut) -> Bool {
        lhs.id == rhs.id
    }
}
```

**Step 4: Run test to verify it passes**

```bash
swift test --filter CustomShortcutTests
```

Expected: PASS

**Step 5: Commit**

```bash
git add .
git commit -m "feat: add CustomShortcut model"
```

---

### Task 8.2: Create ShortcutManager

**Files:**
- Create: `Sources/KeyNav/Shortcuts/ShortcutManager.swift`

**Step 1: Write ShortcutManager**

```swift
// Sources/KeyNav/Shortcuts/ShortcutManager.swift
import Foundation
import AppKit
import HotKey

final class ShortcutManager {
    static let shared = ShortcutManager()

    private var shortcuts: [CustomShortcut] = []
    private var activeHotkeys: [UUID: HotKey] = [:]
    private let accessibilityEngine = AccessibilityEngine()

    private let storageURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let keynavDir = appSupport.appendingPathComponent("KeyNav", isDirectory: true)
        try? FileManager.default.createDirectory(at: keynavDir, withIntermediateDirectories: true)
        return keynavDir.appendingPathComponent("shortcuts.json")
    }()

    private init() {
        loadShortcuts()
    }

    var allShortcuts: [CustomShortcut] {
        shortcuts
    }

    func addShortcut(_ shortcut: CustomShortcut) {
        shortcuts.append(shortcut)
        registerHotkey(for: shortcut)
        saveShortcuts()
    }

    func removeShortcut(id: UUID) {
        shortcuts.removeAll { $0.id == id }
        activeHotkeys[id] = nil
        saveShortcuts()
    }

    func updateShortcut(_ shortcut: CustomShortcut) {
        if let index = shortcuts.firstIndex(where: { $0.id == shortcut.id }) {
            shortcuts[index] = shortcut
            registerHotkey(for: shortcut)
            saveShortcuts()
        }
    }

    private func registerHotkey(for shortcut: CustomShortcut) {
        // Remove existing hotkey
        activeHotkeys[shortcut.id] = nil

        // Parse modifiers
        var modifiers: NSEvent.ModifierFlags = []
        for mod in shortcut.hotkeyModifiers {
            switch mod.lowercased() {
            case "command": modifiers.insert(.command)
            case "shift": modifiers.insert(.shift)
            case "option": modifiers.insert(.option)
            case "control": modifiers.insert(.control)
            default: break
            }
        }

        // Create hotkey (simplified - in real app would map keyCode to Key enum)
        guard let key = Key(carbonKeyCode: UInt32(shortcut.hotkeyCode)) else { return }

        let hotkey = HotKey(key: key, modifiers: modifiers)
        hotkey.keyDownHandler = { [weak self] in
            self?.executeShortcut(shortcut)
        }

        activeHotkeys[shortcut.id] = hotkey
    }

    private func executeShortcut(_ shortcut: CustomShortcut) {
        // Bring app to front
        let runningApps = NSWorkspace.shared.runningApplications
        guard let app = runningApps.first(where: { $0.bundleIdentifier == shortcut.appBundleId }) else {
            // App not running
            return
        }

        app.activate(options: .activateIgnoringOtherApps)

        // Wait for app to activate, then find and click element
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.findAndClickElement(shortcut: shortcut)
        }
    }

    private func findAndClickElement(shortcut: CustomShortcut) {
        accessibilityEngine.getActionableElements { [weak self] elements in
            guard let self = self else { return }

            // Try to find matching element
            let sig = shortcut.elementSignature

            // Primary: match by identifier
            if let identifier = sig.identifier,
               let element = elements.first(where: { $0.identifier == identifier }) {
                self.performAction(shortcut.action, on: element)
                return
            }

            // Secondary: match by label + role
            if let element = elements.first(where: { $0.label == sig.label && $0.role == sig.role }) {
                self.performAction(shortcut.action, on: element)
                return
            }

            // Fallback: fuzzy match on label
            let matcher = FuzzyMatcher()
            if let element = elements.first(where: { matcher.matches(query: sig.label, in: $0.label) }) {
                self.performAction(shortcut.action, on: element)
            }
        }
    }

    private func performAction(_ action: ClickAction, on element: ActionableElement) {
        switch action {
        case .single:
            accessibilityEngine.performClick(on: element)
        case .double:
            accessibilityEngine.performDoubleClick(on: element)
        case .right:
            accessibilityEngine.performRightClick(on: element)
        }
    }

    private func loadShortcuts() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }

        do {
            let data = try Data(contentsOf: storageURL)
            shortcuts = try JSONDecoder().decode([CustomShortcut].self, from: data)

            for shortcut in shortcuts {
                registerHotkey(for: shortcut)
            }
        } catch {
            print("Failed to load shortcuts: \(error)")
        }
    }

    private func saveShortcuts() {
        do {
            let data = try JSONEncoder().encode(shortcuts)
            try data.write(to: storageURL)
        } catch {
            print("Failed to save shortcuts: \(error)")
        }
    }
}
```

**Step 2: Build to verify**

```bash
swift build
```

Expected: Build succeeds.

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add ShortcutManager for custom shortcut persistence and execution"
```

---

## Phase 9: README and License

### Task 9.1: Create README

**Files:**
- Create: `README.md`

**Step 1: Write README**

```markdown
# KeyNav

A free, open-source keyboard navigation app for macOS. Navigate and click any UI element using only your keyboard.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%2012%2B-lightgrey)

## Features

- **Hint Mode** - Press `⌘⇧Space` to show clickable hints on all UI elements. Type to search/filter, then type the hint code to click.
- **Scroll Mode** - Press `⌘⇧J` to scroll using Vim-style keys (H/J/K/L).
- **Search Mode** - Press `⌘⇧/` to search across all visible UI elements in all windows.
- **Custom Shortcuts** - Bind global hotkeys to specific UI elements for one-key actions.

## Installation

### Homebrew

```bash
brew install --cask keynav
```

### Manual Download

Download the latest `.dmg` from [GitHub Releases](https://github.com/yourusername/keynav/releases).

## Requirements

- macOS 12.0 or later
- Accessibility permission (granted on first launch)

## Usage

1. Launch KeyNav - it appears as a keyboard icon in your menu bar
2. Grant Accessibility permission when prompted
3. Press `⌘⇧Space` to activate hint mode
4. Type to filter elements, then type the hint code to click

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘⇧Space` | Activate hint mode |
| `⌘⇧J` | Activate scroll mode |
| `⌘⇧/` | Activate search mode |
| `Escape` | Cancel/exit current mode |

### Scroll Mode Keys

| Key | Action |
|-----|--------|
| `H` | Scroll left |
| `J` | Scroll down |
| `K` | Scroll up |
| `L` | Scroll right |
| `D` | Page down |
| `U` | Page up |
| `G` | Scroll to bottom |
| `gg` | Scroll to top |

## Building from Source

```bash
git clone https://github.com/yourusername/keynav.git
cd keynav/KeyNav
swift build
swift run
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Inspired by [Homerow](https://homerow.app) and [Vimac](https://github.com/nchudleigh/vimac)
- Uses [HotKey](https://github.com/soffes/HotKey) for global hotkey registration
```

**Step 2: Create LICENSE**

```bash
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 KeyNav Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

**Step 3: Commit**

```bash
git add README.md LICENSE
git commit -m "docs: add README and MIT license"
```

---

## Summary

This plan covers:

1. **Phase 1**: Project setup with Swift Package Manager
2. **Phase 2**: Accessibility Engine for element detection
3. **Phase 3**: Hint label generation and fuzzy matching
4. **Phase 4**: Overlay window and hint rendering
5. **Phase 5**: Global hotkey management
6. **Phase 6**: Three modes (hint, scroll, search)
7. **Phase 7**: Coordinator to orchestrate everything
8. **Phase 8**: Custom shortcuts system
9. **Phase 9**: Documentation

**Total tasks**: ~20 discrete implementation steps

Each task follows TDD where applicable and results in a commit, ensuring steady progress and easy rollback if needed.
