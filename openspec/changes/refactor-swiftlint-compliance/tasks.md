# Tasks: Refactor Large Files for SwiftLint Compliance

## 1. PreferencesWindowController Refactoring
- [x] 1.1 Create `ShortcutsPreferencesView.swift` - extract `createShortcutsView()` and related helpers
- [x] 1.2 Create `HintsPreferencesView.swift` - extract `createHintsView()` and related helpers
- [x] 1.3 Create `DiagnosticPreferencesView.swift` - extract `createDiagnosticView()` and related helpers
- [x] 1.4 Update `PreferencesWindowController.swift` to use the new view builders
- [x] 1.5 Verify file length < 500, type length < 300, function lengths < 50

## 2. HotkeyManager Refactoring
- [x] 2.1 Move `HotkeyConfiguration` struct to separate file `HotkeyConfiguration.swift`
- [x] 2.2 Move `HotkeyRegistrationResult` and `HotkeyFailureReason` enums to `HotkeyTypes.swift`
- [x] 2.3 Extract persistence logic to `HotkeyStorage.swift` helper class
- [x] 2.4 Verify file length < 500, type length < 300

## 3. ElementTraversal Refactoring
- [x] 3.1 Extract `getOpenMenuItems()` into `MenuTraversal.swift` helper class
- [x] 3.2 Extract `getMenuBarExtras()` into `MenuBarExtrasTraversal.swift` helper class
- [x] 3.3 Extract `traverseMenuElements()` helper methods to reduce function length
- [x] 3.4 Refactor `getOpenMenuItems()` to reduce cyclomatic complexity (method 1 and 2 as separate helpers)
- [x] 3.5 Verify type length < 300, function lengths < 50, complexity < 10

## 4. KeyboardEventCapture Refactoring
- [x] 4.1 Extract event tap creation to `createEventTap()` private method
- [x] 4.2 Extract run loop setup to `setupRunLoop()` private method
- [x] 4.3 Extract cleanup logic to `cleanupEventTap()` private method
- [x] 4.4 Verify `startCapturing()` function length < 50

## 5. Validation
- [x] 5.1 Run `swiftlint lint` - verify 0 warnings
- [x] 5.2 Run `swift build` - verify successful compilation
- [x] 5.3 Run `swift test` - verify all tests pass (note: one pre-existing test failure in `testScrollModeLogicWithCustomKeys` due to duplicate dictionary keys - not related to this refactoring)
