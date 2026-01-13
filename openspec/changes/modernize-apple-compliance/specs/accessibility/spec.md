# Accessibility Capability

## ADDED Requirements

### Requirement: VoiceOver Hint Labels
Each hint displayed during Hint Mode SHALL have an accessibility label that describes its purpose.

#### Scenario: Hint announces character and target
- **WHEN** VoiceOver is enabled and hints are displayed
- **THEN** each hint SHALL announce its activation character
- **AND** each hint SHALL describe the target UI element type (button, link, text field, etc.)

#### Scenario: VoiceOver navigation through hints
- **WHEN** VoiceOver is enabled and hints are displayed
- **THEN** the user SHALL be able to navigate between hints using VoiceOver gestures
- **AND** hints SHALL be grouped logically by screen region

### Requirement: VoiceOver Input Feedback
The input display view SHALL provide VoiceOver announcements as the user types.

#### Scenario: Character typed announcement
- **WHEN** VoiceOver is enabled and the user types a character during Hint Mode
- **THEN** VoiceOver SHALL announce the current typed sequence
- **AND** the remaining matching hints count SHOULD be announced

#### Scenario: Hint selection announcement
- **WHEN** VoiceOver is enabled and a unique hint is matched
- **THEN** VoiceOver SHALL announce the action being performed
- **AND** VoiceOver SHALL announce success or failure of the action

### Requirement: VoiceOver Search Bar Labels
The search bar in Search Mode SHALL have appropriate accessibility labels.

#### Scenario: Search field announcement
- **WHEN** VoiceOver is enabled and Search Mode is activated
- **THEN** the search field SHALL announce "Search UI elements"
- **AND** the field SHALL have the search field accessibility role

#### Scenario: Search results announcement
- **WHEN** VoiceOver is enabled and search results are displayed
- **THEN** the number of matching results SHALL be announced
- **AND** each result SHALL be navigable via VoiceOver

### Requirement: VoiceOver Preferences Window
The preferences window SHALL be fully accessible via VoiceOver.

#### Scenario: Preferences navigation
- **WHEN** VoiceOver is enabled and the preferences window is open
- **THEN** all form controls SHALL have descriptive labels
- **AND** related controls SHALL be grouped logically

#### Scenario: Hotkey configuration accessibility
- **WHEN** VoiceOver is enabled and the user is configuring hotkeys
- **THEN** the current hotkey binding SHALL be announced
- **AND** instructions for recording a new hotkey SHALL be provided

### Requirement: Accessibility Roles and Traits
All custom UI elements SHALL have appropriate accessibility roles assigned.

#### Scenario: Hint view role
- **WHEN** hints are displayed
- **THEN** each hint view SHALL have the button role
- **AND** each hint SHALL be marked as an accessibility element

#### Scenario: Overlay window role
- **WHEN** an overlay window is displayed
- **THEN** the overlay SHALL have the popover or sheet role as appropriate
- **AND** the overlay SHALL be in the accessibility hierarchy
