# UI System Capability

## ADDED Requirements

### Requirement: Dark Mode Support
The application SHALL automatically adapt its visual appearance to match the system's light or dark mode setting.

#### Scenario: Light mode appearance
- **WHEN** the system appearance is set to Light mode
- **THEN** hint backgrounds SHALL use a pale yellow color (RGB: 255, 224, 112)
- **AND** hint text SHALL be black for maximum contrast
- **AND** overlay backgrounds SHALL use semi-transparent light materials

#### Scenario: Dark mode appearance
- **WHEN** the system appearance is set to Dark mode
- **THEN** hint backgrounds SHALL use a muted gold color (RGB: 115, 102, 38)
- **AND** hint text SHALL be white for maximum contrast
- **AND** overlay backgrounds SHALL use semi-transparent dark materials

#### Scenario: Dynamic appearance change
- **WHEN** the user changes the system appearance while KeyNav is running
- **THEN** all visible UI elements SHALL update their colors immediately
- **AND** no restart of the application SHALL be required

### Requirement: Reduce Transparency Respect
The application SHALL respect the system's Reduce Transparency accessibility setting.

#### Scenario: Reduce transparency enabled
- **WHEN** the user has enabled Reduce Transparency in System Preferences
- **THEN** overlay backgrounds SHALL use solid colors instead of translucent materials
- **AND** visual contrast SHALL be maintained or improved

#### Scenario: Reduce transparency disabled
- **WHEN** the user has not enabled Reduce Transparency
- **THEN** overlay backgrounds MAY use translucent materials for visual depth

### Requirement: Reduce Motion Respect
The application SHALL respect the system's Reduce Motion accessibility setting.

#### Scenario: Reduce motion enabled
- **WHEN** the user has enabled Reduce Motion in System Preferences
- **THEN** hint appearance and disappearance SHALL not use animations
- **AND** UI transitions SHALL be instant

#### Scenario: Reduce motion disabled
- **WHEN** the user has not enabled Reduce Motion
- **THEN** hint appearance and disappearance MAY use subtle animations

### Requirement: Increase Contrast Respect
The application SHALL respect the system's Increase Contrast accessibility setting.

#### Scenario: Increase contrast enabled
- **WHEN** the user has enabled Increase Contrast in System Preferences
- **THEN** hint colors SHALL use higher contrast color combinations
- **AND** text contrast ratio SHALL meet or exceed WCAG AAA standards (7:1)

### Requirement: Auto Layout for Preferences Window
The preferences window SHALL use Auto Layout constraints for responsive sizing.

#### Scenario: Content-driven window sizing
- **WHEN** the preferences window is displayed
- **THEN** the window size SHALL accommodate all content without clipping
- **AND** the window SHALL resize appropriately when content changes

#### Scenario: Large text accessibility
- **WHEN** the user has larger text sizes enabled in System Preferences
- **THEN** preference labels and controls SHALL scale appropriately
- **AND** all text SHALL remain fully visible without truncation
