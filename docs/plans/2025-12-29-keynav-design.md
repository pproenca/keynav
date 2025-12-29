# KeyNav Design Document

**Date:** 2025-12-29
**Status:** Approved
**License:** MIT

## Overview

KeyNav is a free, open-source macOS application that enables keyboard-driven navigation of the entire GUI. It replicates Homerow's functionality with four core features:

1. **Click Hints** - Search-based hints on clickable UI elements
2. **Scroll Mode** - Vim-style keyboard scrolling
3. **UI Search** - Spotlight-like search across all visible elements
4. **Custom Shortcuts** - Persistent hotkeys bound to specific UI elements

### Goals

- Vim-style keyboard navigation across all macOS apps
- Productivity optimization by eliminating mouse usage
- Full feature parity with Homerow from initial release

### Technical Approach

- **Language:** Swift (native)
- **UI Framework:** AppKit (NSWindow, NSView)
- **Core API:** macOS Accessibility API (AXUIElement)
- **Reference:** Based on [Vimac](https://github.com/nchudleigh/vimac) (open source predecessor to Homerow)

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    KeyNav App                        │
├──────────────┬──────────────┬───────────────────────┤
│  Hotkey      │  Accessibility│  Overlay              │
│  Manager     │  Engine       │  Window               │
│  (Carbon/    │  (AXUIElement │  (NSWindow +          │
│   CGEvent)   │   queries)    │   NSView hints)       │
├──────────────┴──────────────┴───────────────────────┤
│              Core Coordinator                        │
│  - Orchestrates activation → detection → rendering  │
│  - Manages mode state (hint/scroll/search)          │
│  - Handles keyboard input during active mode        │
├─────────────────────────────────────────────────────┤
│              Settings & Persistence                  │
│  - UserDefaults for preferences                     │
│  - Custom shortcuts storage                         │
│  - Per-app configurations                           │
└─────────────────────────────────────────────────────┘
```

### Key Components

1. **Hotkey Manager** - Listens for global activation shortcuts
2. **Accessibility Engine** - Queries frontmost window for actionable UI elements
3. **Overlay Window** - Transparent window that renders hints on top of everything
4. **Core Coordinator** - State machine managing the interaction flow

---

## Accessibility Engine

### Detection Flow

```
1. Get frontmost app → AXUIElementCreateApplication(pid)
2. Get focused window → AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute)
3. Recursively traverse → AXUIElementCopyAttributeValue(element, kAXChildrenAttribute)
4. Filter actionable → Check AXRole, AXSubrole, AXEnabled, AXActions
5. Get positions → AXUIElementCopyAttributeValue(element, kAXPositionAttribute/kAXSizeAttribute)
```

### Actionable Element Criteria

An element is considered "clickable" if it:
- Has role: button, link, checkbox, radio button, menu item, cell, etc.
- Has `AXPress` or `AXConfirm` in its actions list
- Is enabled (`AXEnabled = true`)
- Is visible (position within window bounds)

### Performance Optimizations

- Use `AXUIElementCopyMultipleAttributeValues` to batch attribute requests
- Cache element tree during active session
- Background thread for traversal, main thread for rendering

### Element Data Structure

```swift
struct ActionableElement {
    let axElement: AXUIElement
    let role: String
    let label: String          // AXTitle or AXDescription
    let frame: CGRect          // Screen coordinates
    let actions: [String]      // Available AX actions
}
```

---

## Hint Mode

### User Experience

1. Press activation hotkey (`⌘⇧Space`)
2. Search bar appears + hints show on all clickable elements
3. Type to filter elements by their text content
4. Matching elements get short letter codes (A, S, D, F...)
5. Type the code to click, or keep typing to narrow further
6. Single remaining match auto-activates

### Hint Label Algorithm

```swift
let hintChars = "ASDFGHJKLQWERUIO"  // Home row + easy reach

func generateHints(count: Int) -> [String] {
    var hints: [String] = []
    // First pass: single chars
    for char in hintChars.prefix(min(count, hintChars.count)) {
        hints.append(String(char))
    }
    // Second pass: two-char combos if needed
    if count > hintChars.count {
        for first in hintChars {
            for second in hintChars {
                hints.append("\(first)\(second)")
                if hints.count >= count { return hints }
            }
        }
    }
    return hints
}
```

### Overlay Rendering

- `NSWindow` at `.screenSaver` level covering entire screen
- `backgroundColor: .clear`, `ignoresMouseEvents: true`
- `HintView` draws labels at element positions
- Yellow background, black text, rounded corners, drop shadow

### Search Matching

- Case-insensitive substring matching
- Matches against AXTitle, AXDescription, AXValue
- Highlight matched portion in hint display

---

## Scroll Mode

### User Experience

1. Press scroll mode hotkey (`⌘⇧J`)
2. Red border appears around active scrollable area
3. Use Vim keys to scroll:
   - `H` - scroll left
   - `J` - scroll down
   - `K` - scroll up
   - `L` - scroll right
   - `D` - page down
   - `U` - page up
   - `G` - scroll to bottom
   - `gg` - scroll to top
4. `Tab` cycles between scrollable areas
5. `Escape` exits scroll mode

### Implementation

- Find scrollable areas by `AXScrollArea` role or `AXScrollBar` children
- Scroll via `AXUIElementSetAttributeValue` or synthetic `CGEvent` scroll wheel events

---

## UI Search Mode

### User Experience

1. Press search mode hotkey (`⌘⇧/`)
2. Floating search bar appears (centered, Spotlight-style)
3. Type to search across ALL visible UI elements in ALL windows
4. Results show as filterable list with:
   - Element label/text
   - App/window context
   - Element type
5. Arrow keys to navigate, `Enter` to click, `Escape` to dismiss

### Difference from Hint Mode

| Hint Mode | Search Mode |
|-----------|-------------|
| Frontmost window only | All visible windows |
| Visual overlay on elements | List-based results |
| Quick clicks when you see element | Find elements you can't locate |

---

## Custom Shortcuts

### Creating a Shortcut

1. Open KeyNav settings → Custom Shortcuts tab
2. Click "Add Shortcut"
3. Activate hint mode → click target element
4. KeyNav captures element signature:
   - App bundle identifier
   - Element path in hierarchy
   - Element label/identifier
5. Assign global hotkey
6. Save

### Element Matching

Fuzzy matching since UI structure can change:
- Primary: Match by accessibility identifier (most stable)
- Secondary: Match by label + role + position
- Fallback: Notify user if element not found

### Data Structure

```swift
struct CustomShortcut: Codable {
    let id: UUID
    let name: String
    let hotkey: KeyCombo
    let appBundleId: String
    let elementSignature: ElementSignature
    let action: ClickAction  // single, double, right-click
}
```

---

## Settings

### Default Hotkeys

- Hint Mode: `⌘⇧Space`
- Scroll Mode: `⌘⇧J`
- Search Mode: `⌘⇧/`
- Cancel: `Escape`

### Settings Categories

| Tab | Options |
|-----|---------|
| **General** | Launch at login, menu bar icon, sounds, update frequency |
| **Hotkeys** | All activation hotkeys |
| **Appearance** | Hint size, colors, font, position |
| **Apps** | Per-app enable/disable, ignored apps |
| **Shortcuts** | Custom shortcuts manager |

### Persistence

- `UserDefaults` for simple preferences
- JSON file in `~/Library/Application Support/KeyNav/` for custom shortcuts

---

## Error Handling

### Accessibility Permission

1. Check `AXIsProcessTrusted()` on launch
2. Show onboarding if not trusted
3. Guide user to System Preferences > Privacy & Security > Accessibility
4. Poll for permission grant

### Edge Cases

| Situation | Handling |
|-----------|----------|
| No elements found | Show message |
| App lacks accessibility | Show limitation message |
| Element disappears | Graceful fail, dismiss overlay |
| Too many elements (>500) | Show first 500, prompt to filter |
| Multiple monitors | User setting for focused vs all |

---

## Project Structure

```
KeyNav/
├── README.md
├── LICENSE                     # MIT
├── CONTRIBUTING.md
├── .github/workflows/
│   ├── build.yml
│   └── release.yml
├── KeyNav.xcodeproj/
├── KeyNav/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   ├── KeyNavApp.swift
│   │   └── MenuBarController.swift
│   ├── Core/
│   │   ├── Coordinator.swift
│   │   ├── HotkeyManager.swift
│   │   └── Modes/
│   │       ├── HintMode.swift
│   │       ├── ScrollMode.swift
│   │       └── SearchMode.swift
│   ├── Accessibility/
│   │   ├── AccessibilityEngine.swift
│   │   ├── ElementTraversal.swift
│   │   ├── ActionableElement.swift
│   │   └── PermissionManager.swift
│   ├── UI/
│   │   ├── OverlayWindow.swift
│   │   ├── HintView.swift
│   │   ├── SearchBarView.swift
│   │   └── Settings/
│   ├── Shortcuts/
│   │   ├── CustomShortcut.swift
│   │   └── ShortcutManager.swift
│   ├── Utilities/
│   └── Resources/
└── KeyNavTests/
```

### Dependencies

- **Sparkle** - Auto-updates
- **LaunchAtLogin** - Login item management
- **HotKey** - Global hotkey registration

---

## Distribution

### Channels

1. **GitHub Releases** - DMG downloads
2. **Homebrew Cask** - `brew install --cask keynav`
3. **Sparkle** - In-app auto-updates

### Build Pipeline

```
PR → GitHub Actions → Build + Tests → Review
Merge → Build → Sign → Notarize → Release → Update Homebrew + Appcast
```

### Requirements

- Apple Developer ID certificate ($99/year)
- Notarization via `notarytool`
- Hardened runtime

---

## Testing

| Layer | Approach |
|-------|----------|
| Unit tests | Hint generation, fuzzy matching, filtering |
| Integration | Test app with known UI structure |
| Manual | Matrix of popular apps (Safari, Chrome, Finder, VS Code, Slack) |

---

## References

- [Vimac Source Code](https://github.com/nchudleigh/vimac) - GPL v3, same developer as Homerow
- [Homerow](https://www.homerow.app/) - Commercial product we're replicating
- [Apple Accessibility Programming Guide](https://developer.apple.com/library/archive/documentation/Accessibility/Conceptual/AccessibilityMacOSX/)
