# KeyNav TODO - Feature Gap Analysis vs Vimac

Based on a comprehensive audit of Vimac's test files, source code, and feature set.

---

## Priority Legend
- **P0** - Critical for basic functionality
- **P1** - Important for feature parity
- **P2** - Nice to have, improves UX
- **P3** - Advanced features

---

## 1. Hint Mode Features

### P0 - Critical Missing Features

- [x] **Multiple Click Modes**
  - [x] Shift + hint key → right-click
  - [x] Command + hint key → double-click
  - [x] Option + hint key → move mouse only (no click)
  - ~~Current: Only left-click is supported~~
  - Tests: `HintModeModifierTests.swift` (7 tests)

- [x] **Exit Modes**
  - [x] Ctrl+[ to exit (Vim-style escape alternative)
  - ~~Current: Only Escape key exits~~
  - Tests: `HintModeLogicTests.swift`, `HintModeKeyboardCaptureTests.swift`

### P1 - Important Features

- [x] **Hint Rotation/Cycling**
  - [x] Space bar cycles through available hints at same position
  - Useful when multiple elements overlap
  - Tests: `HintModeLogicTests.swift` (4 tests for hint rotation)

- [x] **Trie Data Structure for Hint Matching**
  - Vimac uses efficient Trie for prefix matching
  - Tests: `TrieTests.swift` (14 tests)
    - ~~`test_contains_true` / `test_contains_false`~~
    - ~~`test_is_prefix_true` / `test_is_prefix_false`~~
    - ~~`test_is_prefix_true_when_empty_string`~~
    - ~~`test_does_terminating_prefix_exist_*`~~

- [x] **InputState State Machine**
  - Vimac uses formal state machine for input handling
  - States: `initialized` → `wordsAdded` → `advancable` → `match`/`deadend`
  - Tests: `InputStateTests.swift` (13 tests)
    - ~~`test_add_key_sequence_returns_false_on_duplicate`~~
    - ~~`test_add_key_sequence_returns_false_if_it_is_prefix_of_registered_seq`~~
    - ~~`test_initialized_to_words_added_transition`~~
    - ~~`test_deadend_transition`~~
    - ~~`test_match_transition`~~

- [x] **AXLink Special Positioning**
  - [x] Click at bottom-left corner (offset by 5px) instead of center
  - Links often have clickable text at bottom-left
  - Tests: `ClickPositionTests.swift` (6 tests)

### P2 - UX Improvements

- [x] **Cursor Hiding**
  - [x] Hide cursor during hint mode operation
  - [x] Reduce visual clutter
  - Tests: `CursorHidingTests.swift` (6 tests)

- [x] **Event Suppression**
  - [x] Suppress "doot doot" sounds when Command/Control held
  - [x] CGEvent tap returns nil for consumed events
  - Tests: `EventSuppressionTests.swift` (6 tests)

- [x] **Typed Text Visual Feedback**
  - [x] Color matched hint characters in golden brown RGB(212, 172, 58)
  - [x] Unmatched characters in black
  - Tests: `HintViewStyleTests.swift` (9 tests)

- [x] **Deadend Detection & Analytics**
  - [x] Track when users type invalid sequences
  - [x] Log analytics for UX improvement (HintModeAnalytics)
  - Tests: `DeadendDetectionTests.swift` (7 tests)

---

## 2. Scroll Mode Features

### P0 - Core Scroll Mode

- [x] **Basic Scroll Mode Implementation**
  - [x] HJKL navigation (left/down/up/right)
  - [x] Half-page scrolls: `d` (down), `u` (up)
  - [x] Jump to top: `gg`
  - [x] Jump to bottom: `G`
  - ~~Current: Scroll mode exists but needs verification~~
  - Tests: `ScrollModeTests.swift`, `ScrollModeLogicTests.swift` (24 tests)

### P1 - Scroll Mode Enhancements

- [x] **Configurable Scroll Keys**
  - [x] Allow users to customize scroll key bindings
  - [x] Default: "h,j,k,l,d,u,g,G"
  - Tests: `ScrollKeyConfigTests.swift` (7 tests)

- [x] **Scroll Sensitivity**
  - [x] Configurable scroll amount (0-100 range)
  - [x] Default: 20
  - Tests: `ScrollSensitivityTests.swift` (7 tests)

- [x] **Reversible Scroll Directions**
  - [x] Option to reverse horizontal scroll
  - [x] Option to reverse vertical scroll
  - Tests: `ReverseScrollTests.swift` (5 tests)

- [x] **Chunky vs Smooth Scrolling**
  - [x] Half-page scrolls (chunky): 0.25s interval
  - [x] Directional scrolls (smooth): 1/50s interval
  - Tests: `ScrollTimingTests.swift` (7 tests)

### P2 - Scroll Mode Edge Cases

- [x] **VS Code Compatibility**
  - [x] Use Int16.max instead of Int32.max for upward scrolling
  - [x] VS Code scrolls to bottom with Int32.max
  - Tests: `VSCodeScrollTests.swift` (7 tests)

- [ ] **Scroll Area Detection**
  - Query scroll areas via depth-first traversal
  - Skip web areas (no scroll area children)
  - Use `visibleRows` for tables/outlines
  - Sort by surface area (largest first)
  - Tests needed: `ScrollAreaDetectionTests.swift`

---

## 3. Accessibility & Element Traversal

### P1 - Web Area Handling

- [ ] **WebKit vs Chromium Compatibility**
  - Multi-key search strategy for WebKit
  - Single-key fallback for Chromium (~v90)
  - Tests needed: `WebAreaTraversalTests.swift`

- [ ] **Parameterized Search Predicates**
  - Query: buttons, checkboxes, controls, graphics, links, radio groups, text fields
  - Deduplication of results
  - Tests needed: `SearchPredicateTests.swift`

### P1 - Window Handling

- [ ] **Fullscreen Window Detection**
  - Detect windows on secondary displays in fullscreen
  - `NSScreen.main` returns wrong display in this case
  - Calculate intersection area to find correct screen
  - Tests needed: `FullscreenWindowTests.swift`

- [ ] **Window Frame Boundary Handling**
  - Account for windows extending beyond screen boundaries
  - Tests needed: `WindowBoundaryTests.swift`

### P2 - Element Visibility

- [ ] **Clipped Frame Calculation**
  - Track visible portion of elements within scroll areas
  - Intersect element frames with viewport bounds
  - Tests needed: `ClippedFrameTests.swift`

- [ ] **Table/Outline Optimization**
  - Use `visibleRows` attribute instead of all children
  - Improves performance for large tables
  - Tests needed: `TableTraversalTests.swift`

---

## 4. Activation Methods

### P1 - Hold Key Activation

- [ ] **Space Bar Hold-to-Activate**
  - Hold spacebar for 0.25 seconds to activate
  - Release before timeout replays original keypress
  - Suppress auto-repeat events during hold
  - Handle modifier edge case (Space down, Shift-Space up)
  - Tests needed: `HoldKeyActivationTests.swift`

### P2 - Activation Enhancements

- [ ] **AX Enhanced UI Activation**
  - `AXEnhancedUserInterfaceActivator` for better accessibility
  - Tests needed: `EnhancedUIActivatorTests.swift`

- [ ] **Manual Accessibility Activation**
  - Fallback activation method
  - Tests needed: `ManualActivatorTests.swift`

---

## 5. User Preferences

### P1 - Core Preferences

- [ ] **Custom Hint Characters**
  - Default: "sadfjklewcmpgh"
  - Validation: minimum 6 characters, all unique
  - Tests needed: `HintCharacterPrefsTests.swift`

- [ ] **Hint Text Size**
  - Default: 11.0
  - Validation: float between 0 (exclusive) and 100 (inclusive)
  - Tests needed: `HintTextSizeTests.swift`

### P2 - Scroll Preferences

- [ ] **Scroll Key Bindings**
  - Configurable scroll keys
  - Validation: 4, 6, or 8 comma-separated unique sequences
  - Tests needed: `ScrollKeyPrefsTests.swift`

---

## 6. Input Handling

### P2 - Keyboard Layout Support

- [ ] **CJKV Keyboard Detection**
  - Detect Chinese, Japanese, Korean, Vietnamese layouts
  - Language codes: "ko", "ja", "vi", "zh*"
  - Tests needed: `CJKVKeyboardTests.swift`

- [ ] **Input Source Switching**
  - Programmatic input source switching
  - Read shortcut config from `com.apple.symbolichotkeys`
  - Tests needed: `InputSourceSwitchingTests.swift`

---

## 7. Hint Generation

### P2 - Algorithm Improvements

- [ ] **Vimium-Style Hint Generation**
  - Prepend characters iteratively
  - Reverse and sort for consistent ordering
  - Reference: Vimium link hints implementation
  - Tests needed: Compare with `AlphabetHintsTests.swift`

---

## 8. Visual Polish

### P2 - Hint Styling

- [x] **Hint Colors**
  - [x] Background: RGB(255, 224, 112) - pale yellow
  - [x] Border: dark gray
  - [x] Untyped text: black
  - [x] Typed text: RGB(212, 172, 58) - golden brown
  - Tests: `HintViewStyleTests.swift`

- [x] **Hint Shape**
  - [x] Border width: 1.0
  - [x] Corner radius: 3.0
  - Tests: `HintViewStyleTests.swift`

---

## 9. Missing Tests (Direct from Vimac) - ALL IMPLEMENTED ✓

### InputStateTests ✓
- [x] `test_add_key_sequence_returns_false_on_duplicate`
- [x] `test_add_key_sequence_returns_false_if_it_is_prefix_of_registered_seq`
- [x] `test_add_key_sequence_returns_false_if_prefix_is_already_registered`
- [x] `test_add_key_sequence_returns_true_if_common_prefix_but_unambiguous_end`
- [x] `test_initialized_to_words_added_transition`
- [x] `test_advancing_on_initialized_state`
- [x] `test_deadend_transition`
- [x] `test_words_added_to_advancable_transition`
- [x] `test_match_transition`
- [x] `test_matched_word`

### TrieTests ✓
- [x] `test_contains_true`
- [x] `test_contains_false`
- [x] `test_is_prefix_true`
- [x] `test_is_prefix_true_when_equal`
- [x] `test_is_prefix_false`
- [x] `test_is_prefix_true_when_empty_string`
- [x] `test_is_prefix_false_when_longer`
- [x] `test_does_terminating_prefix_exist_1`
- [x] `test_does_terminating_prefix_exist_2`
- [x] `test_does_terminating_prefix_exist_3`

---

## 10. Architecture Improvements

### P2 - Code Organization

- [ ] **Service-based Architecture**
  - `QueryMenuBarExtrasService`
  - `QueryMenuBarItemsService`
  - `QueryNotificationCenterItemsService`
  - `QueryWindowService`
  - `TraverseElementServiceFinder`
  - Current: Monolithic `ElementTraversal`

- [ ] **Mode Controller Protocol**
  - Formalize `ModeController` protocol
  - Better separation of concerns
  - Tests needed: Protocol conformance tests

---

## Summary Statistics

| Category | P0 | P1 | P2 | P3 | Total | Done |
|----------|----|----|----|----|-------|------|
| Hint Mode | ~~2~~ 0 | ~~5~~ 0 | ~~4~~ 0 | 0 | 11 | 11 ✓ |
| Scroll Mode | ~~1~~ 0 | ~~4~~ 0 | ~~2~~ 1 | 0 | 7 | 6 ✓ |
| Accessibility | 0 | 4 | 2 | 0 | 6 | 0 |
| Activation | 0 | 1 | 2 | 0 | 3 | 0 |
| Preferences | 0 | 2 | 1 | 0 | 3 | 0 |
| Input Handling | 0 | 0 | 2 | 0 | 2 | 0 |
| Visual | 0 | 0 | ~~2~~ 0 | 0 | 2 | 2 ✓ |
| Architecture | 0 | 0 | 2 | 0 | 2 | 0 |
| **Total** | ~~**3**~~ **0** | ~~**16**~~ **7** | ~~**17**~~ **10** | **0** | **36** | **19 ✓** |

---

## Recommended Implementation Order

1. **Phase 1 - Core Parity (P0)**
   - Multiple click modes (right-click, double-click)
   - Exit with Ctrl+[
   - Basic scroll mode verification

2. **Phase 2 - Feature Parity (P1)**
   - Trie/InputState for efficient matching
   - Hint rotation
   - Scroll mode enhancements
   - Web area handling
   - Hold key activation
   - User preferences

3. **Phase 3 - Polish (P2)**
   - Visual improvements
   - CJKV support
   - VS Code workarounds
   - Cursor hiding
   - Analytics

---

## Current Test Coverage

**KeyNav has tests for:**
- ActionableElement (2 tests)
- ClickPosition (6 tests) ← NEW: AXLink positioning
- CursorHiding (6 tests) ← NEW: cursor hiding during hints
- CustomShortcut (1 test)
- DeadendDetection (7 tests) ← NEW: invalid sequence tracking
- ElementTraversal (1 test)
- ElementTraversalMenu (18 tests)
- EventSuppression (6 tests) ← NEW: key event suppression
- FuzzyMatcher (7 tests)
- HintLabelGenerator (4 tests)
- HintModeKeyboardCapture (7 tests) ← +1 for Ctrl+[
- HintModeLogic (24 tests) ← +4 for hint rotation
- HintModeModifier (7 tests) ← NEW: click type modifiers
- HintViewStyle (9 tests) ← NEW: visual feedback colors
- KeyboardEventCapture (5 tests)
- ScrollKeyConfig (7 tests) ← NEW: configurable scroll keys
- ScrollMode (6 tests) ← NEW
- ScrollModeLogic (18 tests) ← NEW
- ScrollSensitivity (7 tests) ← NEW: configurable sensitivity
- ReverseScroll (5 tests) ← NEW: reversible scroll directions
- ScrollTiming (7 tests) ← NEW: chunky vs smooth scrolling
- VSCodeScroll (7 tests) ← NEW: VS Code compatibility
- Trie (14 tests) ← NEW
- InputState (13 tests) ← NEW

**Total: 194 tests** ← was 187

**Vimac has tests for:**
- InputState (10 tests)
- Trie (10 tests)

**Total: ~20 tests** (but covers more complex state machine logic)

---

*Last updated: 2025-12-29*
*Based on Vimac commit analysis*
