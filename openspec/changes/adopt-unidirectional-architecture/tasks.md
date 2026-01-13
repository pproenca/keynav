# Tasks: Adopt Unidirectional Architecture

## 1. Foundation Infrastructure
- [ ] 1.1 Create `Sources/KeyNav/Architecture/` directory structure
- [ ] 1.2 Implement `AppState.swift` with all state types
- [ ] 1.3 Implement `Action.swift` with all action cases
- [ ] 1.4 Implement `Effect.swift` with effect types and runner
- [ ] 1.5 Implement `Reducer.swift` with reducer protocol
- [ ] 1.6 Implement `AppStore.swift` as @MainActor state container
- [ ] 1.7 Implement `Dependencies.swift` with live/mock configurations
- [ ] 1.8 Add unit tests for Effect execution
- [ ] 1.9 Add unit tests for AppStore dispatch

## 2. Bridge Layer (Parallel Operation)
- [ ] 2.1 Initialize AppStore in AppDelegate alongside existing Coordinator
- [ ] 2.2 Create AppStatusBridge to sync AppStore state → AppStatus
- [ ] 2.3 Verify app still works with bridge in place
- [ ] 2.4 Add logging to track action dispatch (debug mode only)

## 3. HintMode Migration
- [ ] 3.1 Create `HintState` modeling all hint mode state
- [ ] 3.2 Create `HintAction` enum with all hint operations
- [ ] 3.3 Create `HintReducer` extracting logic from HintModeLogic
- [ ] 3.4 Create hint effects for accessibility engine calls
- [ ] 3.5 Update HintMode to dispatch actions to AppStore
- [ ] 3.6 Migrate HintModeLogic tests to HintReducer tests
- [ ] 3.7 Remove HintModeLogic (logic now in reducer)
- [ ] 3.8 Verify hint mode works end-to-end

## 4. ScrollMode Migration
- [ ] 4.1 Create `ScrollState` modeling all scroll mode state
- [ ] 4.2 Create `ScrollAction` enum with all scroll operations
- [ ] 4.3 Create `ScrollReducer` extracting logic from ScrollModeLogic
- [ ] 4.4 Update ScrollMode to dispatch actions to AppStore
- [ ] 4.5 Migrate ScrollModeLogic tests to ScrollReducer tests
- [ ] 4.6 Remove ScrollModeLogic
- [ ] 4.7 Verify scroll mode works end-to-end

## 5. SearchMode Migration
- [ ] 5.1 Create `SearchState` modeling all search mode state
- [ ] 5.2 Create `SearchAction` enum with all search operations
- [ ] 5.3 Create `SearchReducer` extracting logic from SearchMode
- [ ] 5.4 Update SearchMode to dispatch actions to AppStore
- [ ] 5.5 Add SearchReducer tests
- [ ] 5.6 Verify search mode works end-to-end

## 6. System State Migration
- [ ] 6.1 Create `SystemReducer` for permissions, hotkeys, event tap
- [ ] 6.2 Migrate PermissionManager checks to effects
- [ ] 6.3 Migrate HotkeyManager registration to effects
- [ ] 6.4 Migrate keyboard event capture setup to effects
- [ ] 6.5 Remove AppStatus.swift (state now in AppStore)
- [ ] 6.6 Update status bar menu to observe AppStore state

## 7. Coordinator Simplification
- [ ] 7.1 Remove mode management from Coordinator (now in AppStore)
- [ ] 7.2 Coordinator becomes action dispatcher only
- [ ] 7.3 Remove delegate callbacks (replaced by state observation)
- [ ] 7.4 Update or remove Coordinator tests

## 8. Singleton Elimination
- [ ] 8.1 Create `AccessibilityEngineProtocol` (already exists, verify)
- [ ] 8.2 Create `HotkeyManagerProtocol` and add to Dependencies
- [ ] 8.3 Create `PermissionCheckerProtocol` and add to Dependencies
- [ ] 8.4 Create `CursorManagerProtocol` and add to Dependencies
- [ ] 8.5 Remove all `.shared` singleton accessors
- [ ] 8.6 Update tests to use mock Dependencies

## 9. UI State Observation
- [ ] 9.1 Update OverlayWindow to observe AppStore state
- [ ] 9.2 Update HintView to render from HintState
- [ ] 9.3 Update SearchBarView to observe SearchState
- [ ] 9.4 Update PreferencesWindow to dispatch preference actions
- [ ] 9.5 Remove direct state mutation from UI components

## 10. Swift 6 Concurrency
- [ ] 10.1 Mark all state types as `Sendable`
- [ ] 10.2 Mark all action types as `Sendable`
- [ ] 10.3 Replace GCD `DispatchQueue.main.async` with `@MainActor`
- [ ] 10.4 Replace GCD background queues with `Task { }`
- [ ] 10.5 Enable strict concurrency checking in Package.swift
- [ ] 10.6 Fix all concurrency warnings
- [ ] 10.7 Enable Swift 6 language mode

## 11. Cleanup & Documentation
- [ ] 11.1 Remove bridge layer (no longer needed)
- [ ] 11.2 Remove deprecated callback patterns
- [ ] 11.3 Update CLAUDE.md with new architecture patterns
- [ ] 11.4 Run full test suite, fix any failures
- [ ] 11.5 Manual testing of all three modes
- [ ] 11.6 Performance profiling (ensure no regression)
