# Design: Unidirectional Architecture

## Context
KeyNav is a macOS accessibility app with three modes (Hint, Scroll, Search) managed by a Coordinator. The current architecture uses:
- 124+ singleton instances for shared state
- GCD callbacks for async operations
- Combine only for AppStatus
- Protocol-oriented design (good foundation)

The codebase will be maintained primarily by AI coding agents (Claude Code), requiring explicit, traceable patterns.

## Goals
- Swift 6 strict concurrency compliance
- AI-agent-friendly architecture (explicit state, traceable mutations)
- Incremental migration (app continues working during transition)
- Preserve existing test coverage

## Non-Goals
- Full TCA adoption (too SwiftUI-focused)
- SwiftUI migration (AppKit works well for this use case)
- Rewriting working accessibility logic

## Decisions

### Decision 1: TCA-Lite over Full TCA
**Choice**: Implement TCA-inspired unidirectional flow without Point-Free dependencies

**Rationale**:
- Full TCA is SwiftUI-focused; KeyNav uses AppKit
- TCA adds significant dependency weight
- Core patterns (Action→Reducer→State) are simple to implement
- Avoids lock-in to external library conventions

**Alternatives considered**:
- Full TCA: Rejected due to SwiftUI focus and dependency weight
- Keep current + modernize: Rejected because scattered state hurts agent maintainability
- Redux-Swift: Less Swift-idiomatic, similar benefits to TCA-Lite

### Decision 2: Actor-based AppStore
**Choice**: Use `@MainActor final class AppStore` as state container

**Rationale**:
- Actors provide thread-safe state without locks
- `@MainActor` ensures UI updates on main thread
- Combine `@Published` enables reactive UI binding
- Simpler than custom threading with GCD

### Decision 3: Explicit Dependencies Container
**Choice**: Replace singletons with `Dependencies` struct passed to reducers

**Rationale**:
- Makes all dependencies visible in function signatures
- Enables test mocking without global state manipulation
- Supports live/mock/preview configurations
- Aligns with Swift 6 strict concurrency (no shared mutable state)

### Decision 4: Effect Type for Side Effects
**Choice**: Custom `Effect<Action>` enum for async operations

```swift
enum Effect<Action: Sendable>: Sendable {
    case none
    case send(Action)
    case run(@Sendable (Send<Action>) async -> Void)
    case merge([Effect])
    case cancel(id: AnyHashable)
}
```

**Rationale**:
- Declarative side effects are easier to trace
- Cancellation support for mode transitions
- Composable (merge multiple effects)
- Testable (effects can be inspected)

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         AppStore                                 │
│  @MainActor final class                                         │
│                                                                  │
│  @Published private(set) var state: AppState                    │
│  private let reducer: Reducer                                    │
│  private let dependencies: Dependencies                          │
│                                                                  │
│  func send(_ action: Action) async {                            │
│      let effect = reducer.reduce(&state, action, dependencies)  │
│      await runEffect(effect)                                    │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  HintReducer    │  │  ScrollReducer  │  │  SearchReducer  │
│  (pure func)    │  │  (pure func)    │  │  (pure func)    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Dependencies                               │
│  struct Dependencies: Sendable {                                │
│      var accessibilityEngine: any AccessibilityEngineProtocol   │
│      var keyboardCapture: any KeyboardEventCaptureProtocol      │
│      var hotkeyManager: any HotkeyManagerProtocol               │
│      var cursorManager: any CursorManagerProtocol               │
│      var permissionChecker: any PermissionCheckerProtocol       │
│      var mainQueue: any SchedulerProtocol                       │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
```

## State Structure

```swift
struct AppState: Equatable, Sendable {
    // System state
    var permissions: PermissionState = .unknown
    var hotkeyRegistration: RegistrationState = .unregistered
    var eventTapStatus: EventTapState = .inactive

    // Mode state
    var activeMode: ModeState = .inactive

    // Feature state
    var hint: HintState = HintState()
    var scroll: ScrollState = ScrollState()
    var search: SearchState = SearchState()

    // Preferences
    var preferences: PreferencesState = PreferencesState()
}

enum ModeState: Equatable, Sendable {
    case inactive
    case hint(HintPhase)
    case scroll(ScrollPhase)
    case search(SearchPhase)
}
```

## Migration Strategy

### Phase 1: Foundation (Non-Breaking)
Add new architecture files alongside existing code:
- `Architecture/AppState.swift`
- `Architecture/Action.swift`
- `Architecture/AppStore.swift`
- `Architecture/Effect.swift`
- `Architecture/Dependencies.swift`
- `Architecture/Reducer.swift`

### Phase 2: Bridge Layer
Create bridge that:
- Initializes AppStore in AppDelegate
- Forwards Coordinator calls to store.send()
- Subscribes AppStatus to store state changes

### Phase 3: Incremental Reducer Migration
Convert one mode at a time:
1. HintMode → HintReducer (largest, most complex)
2. ScrollMode → ScrollReducer (medium complexity)
3. SearchMode → SearchReducer (smallest)

### Phase 4: Singleton Elimination
Replace singleton access with dependency injection:
1. Create protocol for each service
2. Add to Dependencies container
3. Update call sites to use injected dependency
4. Remove .shared accessor

### Phase 5: Swift 6 Concurrency
Enable strict concurrency:
1. Mark all state types Sendable
2. Replace GCD with async/await
3. Fix any remaining concurrency warnings
4. Enable Swift 6 language mode

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Breaking existing functionality | Incremental migration with tests at each step |
| Learning curve for new pattern | Pattern is simpler than full TCA; well-documented |
| Performance overhead | Minimal—reducer dispatch is fast; profile if issues arise |
| Incomplete migration leaves hybrid | Tasks.md enforces completion; no partial states |

## Rollback Plan
Each phase can be rolled back independently:
- Phase 1: Delete new files
- Phase 2: Remove bridge, restore direct calls
- Phase 3: Revert reducer files, restore mode classes
- Phase 4: Restore singleton accessors
- Phase 5: Disable strict concurrency flag

## Open Questions
1. Should we use Combine or AsyncSequence for state observation? (Recommend: Combine for AppKit compatibility)
2. Should effects support dependencies, or capture them at creation? (Recommend: Capture at creation for simplicity)
