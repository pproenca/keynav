## ADDED Requirements

### Requirement: E2E Test Infrastructure
The system SHALL provide XCUITest-based end-to-end tests for the application UI.

#### Scenario: App launch verification
- **WHEN** E2E tests execute `AppLaunchTests`
- **THEN** tests verify the app launches as a menu bar application without a main window

#### Scenario: Menu bar interaction testing
- **WHEN** E2E tests interact with the status item
- **THEN** tests can verify menu items appear and are clickable

#### Scenario: Preferences window testing
- **WHEN** E2E tests open the Preferences window
- **THEN** tests can navigate between Shortcuts, Hints, and Diagnostic tabs

### Requirement: Test Simulation Modes
The application SHALL support launch arguments to simulate different states for testing.

#### Scenario: Permission simulation
- **WHEN** app launches with `--simulate-no-permission`
- **THEN** app behaves as if Accessibility permission is not granted

#### Scenario: Hotkey failure simulation
- **WHEN** app launches with `--simulate-hotkey-failure`
- **THEN** app shows appropriate error state in menu and diagnostic tab

#### Scenario: UI testing mode
- **WHEN** app launches with `--uitesting`
- **THEN** app skips non-essential initializations that interfere with testing

### Requirement: Integration Test Support
The system SHALL provide integration tests for component interaction using mock dependencies.

#### Scenario: Mode lifecycle testing
- **WHEN** integration tests test Coordinator with mock dependencies
- **THEN** mode activation and deactivation can be verified without real system access

#### Scenario: Accessibility engine mocking
- **WHEN** integration tests provide mock ActionableElements
- **THEN** hint mode flow can be tested without real UI element detection

### Requirement: CI Test Automation
The system SHALL provide GitHub Actions workflow for automated test execution.

#### Scenario: Unit test execution
- **WHEN** code is pushed to master or PR opened
- **THEN** unit tests in `KeyNavTests` run automatically

#### Scenario: Integration test execution
- **WHEN** code is pushed to master or PR opened
- **THEN** integration tests in `KeyNavIntegrationTests` run automatically

#### Scenario: UI test execution with skip conditions
- **WHEN** UI tests require Accessibility permission
- **THEN** permission-dependent tests are skipped with `XCTSkipUnless`

### Requirement: Manual Test Documentation
The system SHALL provide a manual test checklist for features that cannot be automated.

#### Scenario: Permission flow manual testing
- **WHEN** tester follows `MANUAL_TESTS.md`
- **THEN** permission grant/revocation flow can be verified step-by-step

#### Scenario: Cross-app interaction manual testing
- **WHEN** tester follows `MANUAL_TESTS.md`
- **THEN** hint/scroll/search modes can be verified in real applications
