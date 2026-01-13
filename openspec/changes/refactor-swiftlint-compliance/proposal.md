# Change: Refactor Large Files for SwiftLint Compliance

## Why
After fixing 64 of 74 SwiftLint violations, 10 structural warnings remain that cannot be resolved without extracting code into separate types/files. These violations impact code maintainability and violate project linting standards.

## What Changes
- **Extract PreferencesWindowController tab views** into separate view builder classes to reduce file/type length
- **Extract HotkeyManager configuration logic** into a separate `HotkeyConfiguration` manager to reduce type length
- **Split ElementTraversal** into focused traversal classes (window, menu, extras) to reduce type length and cyclomatic complexity
- **Extract KeyboardEventCapture setup logic** into helper methods to reduce function length

## Impact
- Affected code:
  - `Sources/KeyNav/UI/PreferencesWindowController.swift` (579 lines → ~350 lines)
  - `Sources/KeyNav/Core/HotkeyManager.swift` (566 lines → ~450 lines)
  - `Sources/KeyNav/Accessibility/ElementTraversal.swift` (438 lines → ~300 lines)
  - `Sources/KeyNav/Core/KeyboardEventCapture.swift` (283 lines, function length only)

## Current Violations

| File | Violation | Current | Limit |
|------|-----------|---------|-------|
| PreferencesWindowController.swift | file_length | 579 | 500 |
| PreferencesWindowController.swift | type_body_length | 345 | 300 |
| PreferencesWindowController.swift:68 | function_body_length | 73 | 50 |
| PreferencesWindowController.swift:320 | function_body_length | 59 | 50 |
| HotkeyManager.swift | file_length | 566 | 500 |
| HotkeyManager.swift | type_body_length | 303 | 300 |
| ElementTraversal.swift | type_body_length | 324 | 300 |
| ElementTraversal.swift:194 | function_body_length | 60 | 50 |
| ElementTraversal.swift:283 | cyclomatic_complexity | 12 | 10 |
| KeyboardEventCapture.swift:87 | function_body_length | 63 | 50 |
