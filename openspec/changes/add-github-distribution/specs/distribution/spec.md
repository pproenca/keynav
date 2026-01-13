## ADDED Requirements

### Requirement: DMG Distribution
The system SHALL be distributed as a signed, notarized DMG disk image hosted on GitHub Releases.

#### Scenario: User downloads app
- **WHEN** user navigates to GitHub Releases page
- **THEN** user can download the latest KeyNav.dmg
- **AND** the DMG is signed with Developer ID
- **AND** the DMG is notarized by Apple

#### Scenario: Gatekeeper approval
- **WHEN** user opens downloaded DMG on a new Mac
- **THEN** Gatekeeper allows the app to run without security warnings

### Requirement: Automatic Update Checking
The system SHALL check for updates via Sparkle framework using an appcast hosted on GitHub Pages.

#### Scenario: Update available
- **WHEN** a new version is published to the appcast
- **AND** user clicks "Check for Updates" in the menu
- **THEN** Sparkle displays the update dialog with release notes
- **AND** user can download and install the update

#### Scenario: No update available
- **WHEN** user is on the latest version
- **AND** user clicks "Check for Updates"
- **THEN** Sparkle displays "You're up to date" message

#### Scenario: Update verification
- **WHEN** Sparkle downloads an update
- **THEN** the update is verified using EdDSA signature
- **AND** tampered updates are rejected

### Requirement: Appcast Feed
The system SHALL maintain an appcast.xml file on GitHub Pages containing version history and download URLs.

#### Scenario: Appcast structure
- **WHEN** Sparkle fetches the appcast URL
- **THEN** it receives valid RSS/XML with Sparkle namespace
- **AND** each item contains version, download URL, and EdDSA signature

#### Scenario: Appcast accessibility
- **WHEN** app checks for updates
- **THEN** appcast is accessible at `https://pproenca.github.io/isitokay-app/appcast.xml`
