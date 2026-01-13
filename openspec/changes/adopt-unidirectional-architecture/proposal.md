# Change: Adopt Unidirectional Architecture

## Why
The current codebase uses callback-based GCD concurrency and 124+ singletons, which creates challenges for:
1. **Swift 6 strict concurrency** - scattered mutable state makes Sendable conformance difficult
2. **AI agent maintainability** - implicit state and callback chains are hard to trace and modify safely

A unidirectional data flow architecture (TCA-Lite) makes state changes explicit, traceable, and testable—critical for a codebase maintained primarily by AI coding agents.

## What Changes
- **ADDED**: Centralized `AppStore` actor as single source of truth
- **ADDED**: `AppState` struct containing all application state
- **ADDED**: `Action` enum for all state mutations
- **ADDED**: Pure reducer functions for state transitions
- **ADDED**: Explicit `Effect` type for side effects
- **ADDED**: `Dependencies` container replacing singletons
- **MODIFIED**: `Coordinator` becomes thin wrapper dispatching actions
- **MODIFIED**: Mode logic classes become pure reducers
- **REMOVED**: Direct singleton access patterns (`.shared`)
- **REMOVED**: Callback-based async patterns (replaced with async/await)

## Impact
- Affected specs: None (no existing specs)
- Affected code:
  - `Sources/KeyNav/App/AppDelegate.swift` - initialize AppStore
  - `Sources/KeyNav/Core/Coordinator.swift` - dispatch actions
  - `Sources/KeyNav/Core/AppStatus.swift` - deprecate (state moves to AppStore)
  - `Sources/KeyNav/Modes/**/*.swift` - convert to reducers
  - `Sources/KeyNav/UI/**/*.swift` - observe state via Combine
  - All singleton `.shared` usages throughout codebase

## Benefits for AI Agents
| Benefit | How |
|---------|-----|
| Find all state | `grep "var " AppState.swift` |
| Find all mutations | `grep "case " Action.swift` |
| Trace any action | `grep "case .actionName" *Reducer.swift` |
| Test changes | Reducers are pure functions |
| No hidden state | Everything in AppState |
| No callback chains | Effects are explicit and composable |
