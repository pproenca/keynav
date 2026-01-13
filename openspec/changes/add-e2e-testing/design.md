## Context
KeyNav is a macOS menu bar accessibility app that requires:
- Accessibility permission (AXIsProcessTrusted)
- CGEvent taps for global keyboard capture
- Global hotkey registration

These system-level requirements make full E2E testing challenging in CI environments.

## Goals / Non-Goals

**Goals:**
- Enable automated testing of app launch, menu bar, and preferences UI
- Enable integration testing of mode lifecycle with mocked dependencies
- Provide CI pipeline for automated test execution
- Document manual test procedures for untestable features

**Non-Goals:**
- Full automation of System Settings interaction
- Testing actual CGEvent tap functionality in CI
- Visual/pixel-perfect overlay testing

## Decisions

### Decision 1: Use XCUITest for E2E tests
**Rationale:** Native Apple framework with direct Xcode/SPM integration. Already compatible with existing XCTest unit tests. Supports menu bar app testing via `app.statusItems`.

**Alternatives considered:**
- Quick/Nimble: Better BDD syntax but adds dependencies
- AXSwift: Good for accessibility testing but requires same permissions as app

### Decision 2: Launch argument simulation for permission states
**Rationale:** Cannot automate System Settings. Launch arguments like `--simulate-no-permission` allow testing error flows without actual permission manipulation.

### Decision 3: Separate integration tests from UI tests
**Rationale:** Integration tests (mode lifecycle, coordinator) can run faster with mocks. UI tests require app bundle and are slower. Separation enables targeted CI jobs.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| UI tests flaky on CI | Use longer timeouts, mark flaky tests with `XCTSkipIf` |
| Cannot test real hotkeys | Integration tests with mocks + manual test checklist |
| Permission-dependent tests fail in CI | Skip with `XCTSkipUnless(AXIsProcessTrusted())` |

## Test Architecture

```
Tests/
├── KeyNavTests/                    # Existing unit tests (43 files)
├── KeyNavIntegrationTests/         # New: Component integration tests
│   ├── CoordinatorIntegrationTests.swift
│   └── ModeFlowIntegrationTests.swift
└── KeyNavUITests/                  # New: XCUITest E2E tests
    ├── Helpers/
    │   └── TestApp.swift
    ├── AppLaunchTests.swift
    ├── MenuBarTests.swift
    ├── PreferencesWindowTests.swift
    └── PermissionFlowTests.swift
```

## Open Questions
- None (proceed with implementation)
