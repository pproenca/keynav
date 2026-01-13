## ADDED Requirements

### Requirement: Unidirectional Data Flow
The application SHALL implement unidirectional data flow where all state mutations occur through a centralized store that processes actions via pure reducer functions.

#### Scenario: Action dispatch modifies state
- **WHEN** any component calls `store.send(action)`
- **THEN** the reducer processes the action and updates AppState
- **AND** all observers receive the updated state

#### Scenario: State is read-only outside reducers
- **WHEN** a component needs to read application state
- **THEN** it observes `store.state` via Combine publisher
- **AND** it does not mutate state directly

### Requirement: Centralized AppState
The application SHALL maintain all mutable application state in a single `AppState` struct that conforms to `Equatable` and `Sendable`.

#### Scenario: State contains all mode state
- **GIVEN** the application has hint, scroll, and search modes
- **WHEN** AppState is defined
- **THEN** it includes `HintState`, `ScrollState`, and `SearchState` as nested properties

#### Scenario: State is thread-safe
- **WHEN** AppState is accessed from any thread
- **THEN** it is safe because AppState is `Sendable` and access is mediated by the `@MainActor` store

### Requirement: Action Enumeration
The application SHALL define all possible state mutations as cases in an `Action` enum that conforms to `Sendable`.

#### Scenario: Mode activation actions
- **WHEN** a hotkey triggers mode activation
- **THEN** an action like `Action.activateHintMode` is dispatched

#### Scenario: Nested feature actions
- **WHEN** a hint-specific event occurs
- **THEN** an action like `Action.hint(.keyPressed(event))` is dispatched

### Requirement: Pure Reducer Functions
State transitions SHALL be implemented as pure functions that take current state and an action, returning new state and optional effects.

#### Scenario: Reducer does not perform side effects
- **WHEN** a reducer processes an action
- **THEN** it only mutates the `inout AppState` parameter
- **AND** returns an `Effect` describing any async work needed

#### Scenario: Reducer is testable without mocks
- **GIVEN** a reducer function and initial state
- **WHEN** an action is applied
- **THEN** the resulting state can be asserted without network, disk, or UI dependencies

### Requirement: Explicit Effect System
Asynchronous operations and side effects SHALL be represented as `Effect` values returned from reducers, not executed inline.

#### Scenario: Accessibility element fetch as effect
- **WHEN** hint mode is activated
- **THEN** the reducer returns `Effect.run { send in ... }` to fetch elements
- **AND** the effect dispatches `Action.hint(.elementsLoaded(...))` when complete

#### Scenario: Effect cancellation on mode change
- **WHEN** user deactivates a mode while effects are running
- **THEN** pending effects for that mode are cancelled

### Requirement: Explicit Dependencies
External services SHALL be accessed through a `Dependencies` container passed to reducers, not via singleton accessors.

#### Scenario: Accessibility engine as dependency
- **WHEN** a reducer needs to fetch UI elements
- **THEN** it accesses `dependencies.accessibilityEngine`
- **AND** does not call `AccessibilityEngine.shared`

#### Scenario: Test dependencies
- **WHEN** testing a reducer
- **THEN** `Dependencies.mock` provides test doubles
- **AND** no global state setup is required

### Requirement: Swift 6 Concurrency Compliance
All architecture types SHALL be compatible with Swift 6 strict concurrency checking.

#### Scenario: Sendable state
- **WHEN** state is passed across actor boundaries
- **THEN** no compiler warnings are produced because all types are `Sendable`

#### Scenario: MainActor UI updates
- **WHEN** state changes occur
- **THEN** UI updates happen on `@MainActor` without explicit dispatch
