# Change: Modernize Apple Guidelines Compliance

## Why

KeyNav is a macOS accessibility tool that currently lacks several modern Apple Human Interface Guidelines (HIG) compliance features. Based on analysis using Apple's iOS/macOS design guidelines:

1. **No Dark Mode support** - Hardcoded yellow hints and black text violate macOS appearance adaptation requirements
2. **Limited VoiceOver integration** - Only the menu bar icon has an accessibility description; UI elements lack labels
3. **Crash-prone code** - 15+ force unwraps throughout Accessibility API calls will crash on nil returns
4. **Hardcoded configuration** - Colors, dimensions, and behavior cannot adapt to user preferences or system settings
5. **Manual layout** - PreferencesWindowController uses 140+ lines of frame calculations instead of Auto Layout
6. **No localization** - All strings are hardcoded in English, blocking international users

These issues affect stability, accessibility compliance, and user experience on modern macOS versions.

## What Changes

### Stability (P0)
- **Safe Unwrapping** - Replace all force unwraps with guard/if-let in Accessibility API calls
- **Error Recovery** - Add graceful degradation when accessibility elements return nil
- **Memory Safety** - Document and verify event tap memory management patterns

### Apple HIG Compliance (P1)
- **Dark Mode Support** - Implement appearance-aware color schemes for hints and overlays
- **VoiceOver Labels** - Add accessibility labels to all UI elements (HintView, InputDisplayView, SearchBarView, PreferencesWindow)
- **System Integration** - Respect Reduce Motion, Reduce Transparency, and Increase Contrast settings
- **Dynamic Type** - Support system font size preferences where applicable

### Modern Architecture (P2)
- **Auto Layout Migration** - Replace manual frame calculations with NSStackView/constraints
- **Configuration System** - Extract hardcoded values into a centralized Configuration struct
- **Semantic Colors** - Replace hardcoded NSColor with system-adaptive semantic colors

### Internationalization (P3)
- **Localization Infrastructure** - Add NSLocalizedString wrapper and .strings file support
- **Initial Localization** - Mark all user-facing strings for localization

## Impact

### Affected Code

| File | Change Type | Impact |
|------|-------------|--------|
| `Sources/KeyNav/UI/HintView.swift` | Major | Dark Mode colors, VoiceOver labels |
| `Sources/KeyNav/UI/InputDisplayView.swift` | Major | Dark Mode colors, VoiceOver labels |
| `Sources/KeyNav/UI/SearchBarView.swift` | Moderate | Dark Mode, VoiceOver |
| `Sources/KeyNav/UI/PreferencesWindowController.swift` | Major | Auto Layout refactor, VoiceOver |
| `Sources/KeyNav/Core/Modes/*.swift` | Moderate | Safe unwrapping, error handling |
| `Sources/KeyNav/Accessibility/ElementTraversal.swift` | Major | Safe unwrapping (15+ force casts) |
| `Sources/KeyNav/Core/KeyboardEventCapture.swift` | Minor | Memory management documentation |
| `Sources/KeyNav/App/AppDelegate.swift` | Moderate | Safe unwrapping, appearance handling |
| New: `Sources/KeyNav/Core/Configuration.swift` | New | Centralized configuration |
| New: `Sources/KeyNav/Resources/*.strings` | New | Localization files |

### Affected Specs
- `ui-system` - New capability for Dark Mode and appearance handling
- `accessibility` - New capability for VoiceOver and accessibility compliance
- `stability` - New capability for error handling patterns

### Breaking Changes
- None - all changes are additive or internal refactoring

### Risk Assessment
- **Low Risk**: Most changes are internal improvements that don't affect user-facing behavior
- **Testing Required**: VoiceOver testing with screen reader enabled
- **Regression Potential**: Auto Layout migration could affect window sizing
