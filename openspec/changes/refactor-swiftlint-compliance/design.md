# Design: Refactor Large Files for SwiftLint Compliance

## Context
The project uses SwiftLint for code quality enforcement with the following limits:
- **file_length**: 500 lines max
- **type_body_length**: 300 lines max
- **function_body_length**: 50 lines max
- **cyclomatic_complexity**: 10 max

Four files exceed these limits, requiring structural refactoring to extract code into separate types/files.

## Goals
- Eliminate all 10 remaining SwiftLint warnings
- Maintain existing public APIs and behavior
- Improve code organization and testability
- Keep changes minimal and focused

## Non-Goals
- Changing any existing functionality
- Introducing new dependencies
- Major architectural changes

## Decisions

### Decision 1: Extract Preferences Views as Builder Classes
**What**: Create separate view builder classes for each preferences tab.

**Why**: `PreferencesWindowController` has 3 large view creation methods (73, 59, and similar lines). Extracting these as standalone classes:
- Reduces controller to coordinator role
- Makes each view independently testable
- Follows Single Responsibility Principle

**Pattern**:
```swift
// New file: ShortcutsPreferencesView.swift
final class ShortcutsPreferencesView {
    weak var delegate: ShortcutsPreferencesDelegate?

    func createView() -> NSView { ... }
    // Helper methods
}

// In PreferencesWindowController.swift
shortcutsTab.view = ShortcutsPreferencesView(delegate: self).createView()
```

### Decision 2: Split HotkeyManager Supporting Types
**What**: Move `HotkeyConfiguration`, `HotkeyRegistrationResult`, and `HotkeyFailureReason` to separate files.

**Why**: These types are already independent (not nested) and account for ~100 lines. Moving them:
- Reduces HotkeyManager.swift below 500 lines
- Groups related types in dedicated files
- No API changes required

**Structure**:
```
Core/
├── HotkeyManager.swift      # Core manager class (~450 lines)
├── HotkeyConfiguration.swift # Configuration struct + display logic
└── HotkeyTypes.swift        # Result and failure enums
```

### Decision 3: Extract Traversal Helpers from ElementTraversal
**What**: Create focused helper classes for menu and extras traversal.

**Why**: `getOpenMenuItems()` has complexity 12 due to two distinct traversal methods. Extracting:
- Reduces main class below 300 lines
- Separates menu detection strategies
- Makes complex logic testable in isolation

**Pattern**:
```swift
// ElementTraversal remains the public API
final class ElementTraversal {
    private let menuTraversal = MenuTraversal()

    func getOpenMenuItems(from app: AXUIElement) -> [ActionableElement] {
        return menuTraversal.findOpenMenus(from: app)
    }
}

// MenuTraversal handles the complexity
final class MenuTraversal {
    func findOpenMenus(from app: AXUIElement) -> [ActionableElement] {
        var results = findMenusFromFocusedElement(app)
        results.append(contentsOf: findMenusFromWindows(app))
        return results
    }

    private func findMenusFromFocusedElement(_ app: AXUIElement) -> [ActionableElement] { ... }
    private func findMenusFromWindows(_ app: AXUIElement) -> [ActionableElement] { ... }
}
```

### Decision 4: Extract Event Tap Setup Steps
**What**: Split `startCapturing()` into 3 focused helper methods.

**Why**: The 63-line function has clear phases: create tap, setup run loop, handle failure. Extracting:
- Each phase becomes a focused method
- Main function reads as high-level steps
- No new files needed (private methods only)

**Pattern**:
```swift
func startCapturing() {
    guard !isCapturing else { return }
    reEnableAttempts = 0

    guard let tap = createEventTap() else {
        handleEventTapCreationFailure()
        return
    }

    guard setupRunLoop(for: tap) else {
        handleRunLoopSetupFailure()
        return
    }

    isCapturing = true
    AppStatus.shared.updateEventTapStatus(.operational)
}

private func createEventTap() -> CFMachPort? { ... }
private func setupRunLoop(for tap: CFMachPort) -> Bool { ... }
private func handleEventTapCreationFailure() { ... }
private func handleRunLoopSetupFailure() { ... }
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Breaking existing tests | Run full test suite after each file extraction |
| Introducing bugs | No logic changes, pure structural refactoring |
| Over-engineering | Keep extractions minimal, only what's needed for compliance |

## Open Questions
None - this is a straightforward structural refactoring with clear targets.
