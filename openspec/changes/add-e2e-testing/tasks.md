## 1. Test Infrastructure Setup
- [x] 1.1 Add `KeyNavUITests` test target to `Package.swift`
- [x] 1.2 Add `KeyNavIntegrationTests` test target to `Package.swift`
- [x] 1.3 Create `Tests/KeyNavUITests/` directory structure
- [x] 1.4 Create `Tests/KeyNavIntegrationTests/` directory structure

## 2. Launch Argument Support
- [x] 2.1 Add `--uitesting` launch argument handling in `AppDelegate.swift`
- [x] 2.2 Add `--simulate-no-permission` handling to force permission denied state
- [x] 2.3 Add `--simulate-hotkey-failure` handling to simulate registration failure

## 3. E2E Test Helpers
- [x] 3.1 Create `TestApp.swift` XCUIApplication wrapper with helper methods
- [ ] 3.2 Create `XCTestCase+Helpers.swift` with common test utilities (deferred - helpers integrated into TestApp)

## 4. App Launch Tests
- [x] 4.1 Create `AppLaunchTests.swift`
- [x] 4.2 Test app launches as menu bar app (no main window)
- [x] 4.3 Test status item appears in menu bar
- [x] 4.4 Test status item shows menu on click

## 5. Menu Bar Tests
- [x] 5.1 Tests included in `AppLaunchTests.swift` (consolidated)
- [x] 5.2 Test menu shows status indicator
- [x] 5.3 Test Preferences menu item works
- [x] 5.4 Test Troubleshoot appears when issues detected

## 6. Preferences Window Tests
- [x] 6.1 Create `PreferencesTests.swift` (consolidated preferences tests)
- [x] 6.2 Test window opens via menu
- [x] 6.3 Test all three tabs exist (Shortcuts, Hints, Diagnostic)
- [x] 6.4 Test tab navigation works

## 7. Tab-Specific Tests
- [x] 7.1 Shortcuts tab tests included in `PreferencesTests.swift`
- [ ] 7.2 Create `HintsTabTests.swift` - deferred (requires Xcode to run XCUITest)
- [x] 7.3 Diagnostic tab tests included in `PreferencesTests.swift`

## 8. Permission Flow Tests
- [x] 8.1 Permission flow tests included in `PreferencesTests.swift`
- [x] 8.2 Test onboarding window appears with `--simulate-no-permission`
- [x] 8.3 Test Open System Settings button exists
- [ ] 8.4 Test diagnostic tab shows permission status (requires Xcode to run)

## 9. Integration Tests
- [x] 9.1 Create `TestModeTests.swift` (TestMode configuration tests)
- [x] 9.2 Create `ModeLifecycleIntegrationTests.swift`
- [x] 9.3 Test full mode activation cycle with mocks
- [x] 9.4 Test mode manager and key input handling

## 10. CI/CD Integration
- [x] 10.1 Create `.github/workflows/test.yml`
- [x] 10.2 Add job for unit tests (`KeyNavTests`)
- [x] 10.3 Add job for integration tests (`KeyNavIntegrationTests`)
- [ ] 10.4 Add job for UI tests (`KeyNavUITests`) - deferred (requires Xcode project)

## 11. Documentation
- [x] 11.1 Create `MANUAL_TESTS.md` checklist for features requiring manual testing
- [x] 11.2 Create `Tests/KeyNavUITests/README.md` with setup instructions

## 12. Validation
- [x] 12.1 Run `swift test --filter KeyNavTests` - 349 tests pass
- [x] 12.2 Run `swift test --filter KeyNavIntegrationTests` - 10 tests pass
- [ ] 12.3 Build and run UI tests locally (requires Xcode)
- [ ] 12.4 Push and verify CI workflow passes
