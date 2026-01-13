# Design: Modernize Apple Guidelines Compliance

## Context

KeyNav is a macOS accessibility tool that enables keyboard navigation of UI elements. The application was built with AppKit and targets macOS 13.0+. The codebase has solid architecture with good test coverage but lacks modern macOS HIG compliance features.

This design document covers technical decisions for:
1. Safe API handling patterns
2. Dark Mode implementation strategy
3. VoiceOver accessibility approach
4. Configuration architecture
5. Auto Layout migration strategy

## Goals / Non-Goals

### Goals
- Eliminate crash-causing force unwraps without changing user-visible behavior
- Implement Dark Mode that automatically adapts to system appearance
- Add VoiceOver support sufficient for screen reader users to operate the app
- Create configuration system that allows future preference expansion
- Migrate to Auto Layout for maintainable UI code

### Non-Goals
- Complete localization to other languages (infrastructure only)
- Custom theming beyond light/dark (no user-selectable themes)
- Accessibility certification (WCAG AA compliance)
- SwiftUI migration (staying with AppKit)

## Decisions

### 1. Safe Unwrapping Pattern

**Decision**: Use guard-let with early return and optional logging for all Accessibility API calls.

**Pattern**:
```swift
// Before (crash on nil)
let window = windowRef as! AXUIElement

// After (safe with logging)
guard let window = windowRef as? AXUIElement else {
    Logger.accessibility.debug("Window reference was nil or wrong type")
    return nil
}
```

**Alternatives Considered**:
- **Force try with do-catch**: AX APIs don't throw, they return nil
- **Implicitly unwrapped optionals**: Still crashes, just deferred
- **Optional chaining only**: Loses ability to log failures

**Rationale**: Guard statements provide clear control flow, enable logging for debugging, and prevent crashes. The pattern is consistent with Swift best practices and AppKit conventions.

### 2. Dark Mode Color Strategy

**Decision**: Create a centralized `AppearanceColors` struct that provides appearance-aware colors using `NSColor` dynamic providers.

**Pattern**:
```swift
struct AppearanceColors {
    static let hintBackground = NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return NSColor(calibratedRed: 0.45, green: 0.40, blue: 0.15, alpha: 0.95)
        default:
            return NSColor(calibratedRed: 1.0, green: 0.88, blue: 0.44, alpha: 1.0)
        }
    }

    static let hintText = NSColor(name: nil) { appearance in
        switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
        case .darkAqua:
            return .white
        default:
            return .black
        }
    }
}
```

**Alternatives Considered**:
- **Asset Catalog Colors**: Requires XIB/Storyboard; app uses programmatic UI
- **Manual appearance observation**: More code, same result
- **System semantic colors only**: Yellow theme is intentional brand identity

**Rationale**: Dynamic NSColor providers automatically update when appearance changes. This matches how system colors work and requires minimal code changes in existing views.

### 3. VoiceOver Implementation Approach

**Decision**: Implement NSAccessibility protocol on custom views with meaningful labels and roles.

**Pattern for HintView**:
```swift
extension HintView: NSAccessibilityElement {
    override func isAccessibilityElement() -> Bool { return true }
    override func accessibilityRole() -> NSAccessibility.Role? { return .button }
    override func accessibilityLabel() -> String? {
        return "Hint \(hintCharacter) for \(elementDescription)"
    }
}
```

**Key Accessibility Elements**:
| View | Role | Label Format |
|------|------|--------------|
| HintView | Button | "Hint [char] for [element]" |
| InputDisplayView | StaticText | "Typed: [characters]" |
| SearchBarView | SearchField | "Search UI elements" |
| PreferencesWindow | Window | "KeyNav Preferences" |

**Alternatives Considered**:
- **NSAccessibility.setAccessibility**: Deprecated, use protocol
- **accessibilityChildren only**: Misses direct element support
- **Third-party accessibility library**: Unnecessary complexity

**Rationale**: NSAccessibility protocol is the standard macOS approach. The pattern allows VoiceOver to navigate hints as individual elements and announce meaningful context.

### 4. Configuration Architecture

**Decision**: Use a `Configuration` struct with UserDefaults backing and Combine publishers for changes.

**Pattern**:
```swift
struct Configuration {
    struct Hint {
        @AppStorage("hintCharacters") var characters = "sadfjklewcmpgh"
        @AppStorage("hintFontSize") var fontSize: CGFloat = 11.0
    }

    struct Scroll {
        @AppStorage("scrollAmount") var amount: CGFloat = 50
        @AppStorage("pageScrollAmount") var pageAmount: CGFloat = 300
    }

    struct Appearance {
        var shouldReduceMotion: Bool {
            NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        }
        var shouldReduceTransparency: Bool {
            NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
        }
    }

    static let shared = Configuration()
    let hint = Hint()
    let scroll = Scroll()
    let appearance = Appearance()
}
```

**Alternatives Considered**:
- **Global constants**: Not user-configurable
- **Plist file**: More complex than UserDefaults
- **Environment injection**: Good for testing but overkill for simple config

**Rationale**: `@AppStorage` provides automatic persistence and SwiftUI-style observation. The nested struct pattern organizes settings by domain. System accessibility settings are computed properties that always reflect current state.

### 5. Auto Layout Migration Strategy

**Decision**: Migrate PreferencesWindowController incrementally using NSStackView with constraints.

**Approach**:
1. Create new `PreferencesContentView` class using NSStackView
2. Build each section (General, Hotkeys, About) as separate stack views
3. Replace PreferencesWindowController's manual layout with the new view
4. Maintain exact same visual appearance

**Pattern**:
```swift
class PreferencesContentView: NSView {
    private lazy var mainStack: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private func setupHotkeySection() -> NSView {
        let section = NSStackView()
        section.orientation = .vertical
        section.spacing = 8

        for hotkey in hotkeys {
            section.addArrangedSubview(createHotkeyRow(hotkey))
        }
        return section
    }
}
```

**Alternatives Considered**:
- **SwiftUI with NSHostingView**: Introduces mixed paradigm; keep AppKit pure
- **XIB/Storyboard**: Adds build complexity; programmatic is working
- **Rewrite from scratch**: Risk of regressions; incremental is safer

**Rationale**: Incremental migration minimizes risk. NSStackView handles most layout complexity. The pattern matches modern AppKit applications and enables future accessibility improvements.

## Risks / Trade-offs

### Risk: Dark Mode Colors May Not Match User Expectations
**Mitigation**: Test with real users. Start with muted gold that maintains hint visibility. Can adjust colors based on feedback.

### Risk: Auto Layout Migration Could Break Window Sizing
**Mitigation**:
- Add unit tests for preferred content size
- Test at multiple display scales before merging
- Keep old code available for rollback

### Risk: VoiceOver Announcements May Be Too Verbose
**Mitigation**:
- Test with VoiceOver users
- Use `accessibilityValue` for dynamic content, `accessibilityLabel` for static
- Implement `accessibilityElement(children: .ignore)` to reduce noise

### Trade-off: Configuration System Adds Complexity
**Accepted**: The benefit of user customization and cleaner code outweighs the small increase in architecture complexity.

## Migration Plan

### Phase 1: Stability (No User-Visible Changes)
1. Replace force unwraps - pure refactoring, same behavior
2. Add tests for nil handling paths
3. Verify all existing tests still pass

### Phase 2: Dark Mode (Visual Changes Only When Appearance Changes)
1. Implement AppearanceColors
2. Update views to use new colors
3. Test in light mode (should look identical to current)
4. Test in dark mode (new appearance)

### Phase 3: VoiceOver (Additive - No Changes for Non-VoiceOver Users)
1. Add accessibility labels
2. Test with VoiceOver
3. Iterate based on testing feedback

### Phase 4: Auto Layout (Visual Parity Required)
1. Create new PreferencesContentView
2. Screenshot comparison testing
3. Replace old layout code

### Rollback Plan
- Each phase is independently deployable
- Git tags at each phase completion
- Feature flags not needed (all changes are backwards compatible)

## Open Questions

1. **Hint Color in Dark Mode**: Should hints be gold/amber (warm) or blue/cyan (cool) in dark mode? Current proposal: warm gold to maintain brand identity.

2. **VoiceOver for Hints During Active Mode**: When user is typing hint characters, should VoiceOver announce each keystroke? Concern: might slow down power users.

3. **Configuration UI**: Should new configuration options (like hint colors) be exposed in preferences, or only via defaults write? Current proposal: start with defaults, add UI if requested.
