# Project Context

## Purpose
KeyNav is a free, open-source keyboard navigation application for macOS that enables users to navigate and interact with UI elements using only their keyboard. It's an accessibility-focused tool inspired by Homerow and Vimac.

**Primary Modes:**
- **Hint Mode** (default: Cmd+Shift+Space): Shows clickable hints on all UI elements, allowing users to type to filter and select
- **Scroll Mode** (default: Cmd+Shift+J): Provides Vim-style scrolling (H/J/K/L keys)
- **Search Mode** (default: Cmd+Shift+/): Search across all visible UI elements

## Tech Stack
- **Language:** Swift 5.9+
- **Platform:** macOS 13.0+
- **UI Framework:** AppKit (native macOS)
- **Package Manager:** Swift Package Manager

**Dependencies:**
- **HotKey** (v0.2.0+) - Global hotkey registration
- **LaunchAtLogin-Modern** (v1.0.0+) - Launch-at-login functionality
- **Sparkle** (v2.0.0+) - Auto-update framework
- **ApplicationServices** - macOS accessibility framework
- **Carbon** - Key code handling

## Project Conventions

### Code Style
- Swift standard naming conventions (camelCase for properties/methods, PascalCase for types)
- Protocol-oriented design for testability
- Separation of controller and business logic (e.g., `HintMode.swift` + `HintModeLogic.swift`)
- Codable structs for persistent configuration types

### Architecture Patterns
- **Singleton Pattern:** Core services use singletons (`Coordinator.shared`, `AppStatus.shared`, `PermissionManager.shared`, `HotkeyManager.shared`)
- **Delegate Pattern:** Mode delegates for event handling (HintModeDelegate, ScrollModeDelegate, SearchModeDelegate)
- **Protocol-Oriented Design:** Protocols for dependencies to enable testing (AccessibilityEngineProtocol, KeyboardEventCapture)
- **Observer Pattern:** AppStatus uses Combine @Published for reactive UI updates
- **Dependency Injection:** Production code uses convenience initializers; tests inject mock dependencies

**Project Structure:**
```
Sources/KeyNav/
├── main.swift                    # Entry point
├── App/                          # Application lifecycle
├── Accessibility/                # UI element detection & permissions
├── Core/
│   ├── Coordinator.swift         # Central orchestrator
│   ├── HotkeyManager.swift       # Global hotkey management
│   ├── KeyboardEventCapture.swift
│   ├── AppStatus.swift           # Centralized status tracking
│   ├── Modes/                    # Mode implementations
│   ├── DataStructures/           # Trie, InputState
│   └── Services/
├── UI/                           # Views, windows, overlays
├── Utilities/                    # FuzzyMatcher, HintLabelGenerator
└── Resources/                    # Info.plist, assets
```

### Testing Strategy
- Unit tests located in `Tests/KeyNavTests/`
- Protocol-based dependencies enable mocking
- Test coverage for: Trie operations, Scroll mode, CJKV keyboard handling, Input source switching, Web area traversal
- Convenience initializers for production use; dependency injection for test isolation

### Git Workflow
- Main branch: `master`
- OpenSpec workflow for significant changes (proposal -> tasks -> design -> implementation)

## Domain Context
- **Accessibility APIs:** Uses macOS Accessibility framework (AXUIElement) to traverse UI element trees
- **Menu Detection:** Special handling for menu elements which can appear as focused windows
- **Element Deduplication:** Elements are deduplicated by frame geometry to avoid duplicate hints
- **CJKV Support:** Keyboard input detector for non-Latin character input methods
- **Web Content:** Special traversal handling for web content in accessibility tree

**Key Concepts:**
- **ActionableElement:** Model representing an interactive UI element with position, label, and actions
- **ElementTraversal:** Recursive tree walking of the accessibility hierarchy
- **SubsystemStatus:** Enum tracking health of each subsystem (unknown, operational, failed, disabled)

## Important Constraints
- Requires macOS Accessibility permission to function
- Onboarding flow guides users through permission grant process
- Permission can be revoked at runtime; app monitors for revocation
- Global hotkeys may conflict with other applications
- Performance-sensitive: accessibility tree traversal must be fast for responsive UX

## External Dependencies
- **Sparkle:** Auto-update feed served from `https://keynav.app/appcast.xml`
- **macOS Accessibility Framework:** Core dependency for UI element detection
- No network dependencies for core functionality (works offline)

## Build & Release
- Build: `scripts/build-app.sh`
- Create DMG: `scripts/create-dmg.sh`
- Notarize: `scripts/notarize.sh`
- Update appcast: `scripts/update-appcast.sh`
