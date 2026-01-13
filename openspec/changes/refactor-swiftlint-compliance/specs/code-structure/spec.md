## ADDED Requirements

### Requirement: Preferences View Extraction
The PreferencesWindowController SHALL delegate view creation to separate view builder classes for each preferences tab (Shortcuts, Hints, Diagnostic).

#### Scenario: Shortcuts preferences view builder
- **WHEN** the Shortcuts tab is displayed
- **THEN** `ShortcutsPreferencesView` creates and returns the view
- **AND** all shortcut-related UI logic resides in the view builder class

#### Scenario: Hints preferences view builder
- **WHEN** the Hints tab is displayed
- **THEN** `HintsPreferencesView` creates and returns the view
- **AND** all hint customization UI logic resides in the view builder class

#### Scenario: Diagnostic preferences view builder
- **WHEN** the Diagnostic tab is displayed
- **THEN** `DiagnosticPreferencesView` creates and returns the view
- **AND** all diagnostic UI logic resides in the view builder class

### Requirement: Hotkey Type Separation
The HotkeyManager supporting types SHALL be organized in separate files for improved maintainability.

#### Scenario: Configuration type in dedicated file
- **WHEN** hotkey configuration is needed
- **THEN** `HotkeyConfiguration` struct is available from `HotkeyConfiguration.swift`
- **AND** the struct includes display string generation logic

#### Scenario: Result types in dedicated file
- **WHEN** hotkey registration results are needed
- **THEN** `HotkeyRegistrationResult` and `HotkeyFailureReason` are available from `HotkeyTypes.swift`

### Requirement: Menu Traversal Extraction
The ElementTraversal class SHALL delegate menu-related traversal to a dedicated `MenuTraversal` helper class.

#### Scenario: Open menu detection via focused element
- **WHEN** searching for open menus
- **THEN** `MenuTraversal` checks the focused UI element for menu roles
- **AND** traverses parent elements to find menu containers

#### Scenario: Open menu detection via windows
- **WHEN** searching for open menus
- **THEN** `MenuTraversal` checks all windows for menu subroles
- **AND** traverses window children for AXMenu elements

### Requirement: Event Tap Setup Extraction
The KeyboardEventCapture `startCapturing()` method SHALL be organized into focused helper methods for each setup phase.

#### Scenario: Event tap creation phase
- **WHEN** starting keyboard capture
- **THEN** `createEventTap()` creates the CGEvent tap with the callback
- **AND** returns nil on failure without side effects

#### Scenario: Run loop setup phase
- **WHEN** event tap is created successfully
- **THEN** `setupRunLoop(for:)` creates the run loop source and adds it
- **AND** returns false on failure

#### Scenario: Failure handling
- **WHEN** event tap creation or run loop setup fails
- **THEN** dedicated handler methods clean up resources
- **AND** update AppStatus with appropriate failure reason
