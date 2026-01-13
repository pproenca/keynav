# KeyNav UI Tests

This directory contains UI/E2E tests for the KeyNav application. Due to limitations of Swift Package Manager with UI testing, these tests require Xcode to run.

## Running UI Tests

### Option 1: Open in Xcode (Recommended)

1. Open the package in Xcode:
   ```bash
   open Package.swift
   ```

2. Select the KeyNav scheme

3. Run UI tests with Cmd+U or Product > Test

### Option 2: Generate Xcode Project

```bash
# Generate an Xcode project (deprecated but still works)
swift package generate-xcodeproj

# Open the generated project
open KeyNav.xcodeproj
```

## Test Files

- `TestApp.swift` - XCUIApplication wrapper with helper methods
- `AppLaunchTests.swift` - Tests for app launch and menu bar
- `PreferencesTests.swift` - Tests for preferences window

## Launch Arguments

The app supports these launch arguments for testing:

- `--uitesting` - Disables auto-update checks
- `--simulate-no-permission` - Simulates permission denied state
- `--simulate-hotkey-failure` - Simulates hotkey registration failure

## Known Limitations

1. **Accessibility Permission**: The test runner needs Accessibility permission to interact with the app
2. **Menu Bar Apps**: XCUITest has limited support for menu bar apps
3. **Global Hotkeys**: Cannot test actual hotkey functionality in UI tests

## Manual Testing

For features that cannot be automated, see `MANUAL_TESTS.md` in the project root.
