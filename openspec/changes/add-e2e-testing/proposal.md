# Change: Add End-to-End Testing Infrastructure

## Why
KeyNav has 43 unit test files but lacks E2E and UI automation tests. Users want to test the real application including the full user journey (launch → permission flow → modes) and preferences. This enables regression testing and increases confidence in releases.

## What Changes
- Add XCUITest-based E2E test infrastructure for testing the actual application
- Add integration tests for mode lifecycle with mocked system dependencies
- Add launch argument support in AppDelegate for test simulation modes
- Add GitHub Actions CI workflow for automated test execution
- Create manual test checklist for features that cannot be automated

## Impact
- Affected specs: New `testing` capability
- Affected code:
  - `Package.swift` - new test targets
  - `Sources/KeyNav/App/AppDelegate.swift` - launch argument support
  - `Tests/KeyNavUITests/` - new E2E test directory
  - `Tests/KeyNavIntegrationTests/` - new integration test directory
  - `.github/workflows/test.yml` - new CI workflow
