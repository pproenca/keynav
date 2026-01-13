# Tasks: Modernize Apple Guidelines Compliance

## 1. Stability - Safe Unwrapping (P0)

- [ ] 1.1 Replace force unwraps in `ElementTraversal.swift` with safe casting
  - Replace `windowRef as! AXUIElement` with guard statements
  - Replace `elementRef as! AXUIElement` with optional binding
  - Replace `menuBarRef as! AXUIElement` with safe unwrapping
  - Add logging for nil cases to aid debugging

- [ ] 1.2 Replace force unwraps in mode files
  - `HintMode.swift:99` - `overlayWindow!.frame` to guard statement
  - `SearchMode.swift:62` - `overlayWindow!.frame` to guard statement
  - `ScrollMode.swift:107-117` - AXValue casts to safe patterns

- [ ] 1.3 Replace force unwraps in `AppDelegate.swift`
  - Line 151 - `window.contentView!.bounds` to optional binding

- [ ] 1.4 Remove fatal error from `PreferencesWindowController.swift`
  - Replace `fatalError("init(coder:) has not been implemented")` with appropriate handling

- [ ] 1.5 Add unit tests for nil handling paths
  - Test behavior when accessibility API returns nil elements
  - Test mode activation with missing windows

## 2. Dark Mode Support (P1)

- [ ] 2.1 Create appearance-aware color system
  - Create `AppearanceColors.swift` with adaptive color definitions
  - Define light/dark mode hint colors (yellow theme for light, muted gold for dark)
  - Define background overlay colors for both modes

- [ ] 2.2 Update `HintView.swift` for Dark Mode
  - Replace hardcoded `hintBackgroundColor` with appearance-aware color
  - Replace hardcoded `hintTextColor` with semantic color
  - Add appearance change observation

- [ ] 2.3 Update `InputDisplayView.swift` for Dark Mode
  - Replace hardcoded black background with adaptive color
  - Ensure text contrast meets WCAG 4.5:1 ratio in both modes

- [ ] 2.4 Update `SearchBarView.swift` for Dark Mode
  - Use semantic colors for search bar background
  - Ensure placeholder and typed text are legible in both modes

- [ ] 2.5 Test Dark Mode transitions
  - Verify colors update when system appearance changes
  - Test with "Auto" appearance setting

## 3. VoiceOver Accessibility (P1)

- [ ] 3.1 Add accessibility labels to `HintView`
  - Set `accessibilityLabel` with hint character and target description
  - Set `accessibilityRole` to `.button` or `.staticText` as appropriate
  - Group hints logically for VoiceOver navigation

- [ ] 3.2 Add accessibility labels to `InputDisplayView`
  - Announce current typed characters
  - Update label dynamically as user types

- [ ] 3.3 Add accessibility labels to `SearchBarView`
  - Label search field appropriately
  - Announce search results count

- [ ] 3.4 Add accessibility to `PreferencesWindowController`
  - Label all form fields
  - Group related controls
  - Ensure tab navigation order is logical

- [ ] 3.5 Test with VoiceOver enabled
  - Complete hint activation workflow with VoiceOver
  - Navigate preferences with VoiceOver
  - Document any remaining accessibility gaps

## 4. System Preference Respect (P1)

- [ ] 4.1 Respect Reduce Motion preference
  - Check `NSWorkspace.shared.accessibilityDisplayShouldReduceMotion`
  - Disable animations when reduce motion is enabled

- [ ] 4.2 Respect Reduce Transparency preference
  - Check `NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency`
  - Use solid colors instead of materials when enabled

- [ ] 4.3 Respect Increase Contrast preference
  - Check `NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast`
  - Use higher contrast color combinations when enabled

## 5. Auto Layout Migration (P2)

- [ ] 5.1 Create `PreferencesView` using NSStackView
  - Define layout using stack views and constraints
  - Maintain current visual appearance
  - Support dynamic content sizing

- [ ] 5.2 Migrate hotkey configuration section
  - Create reusable hotkey row component
  - Use Auto Layout for responsive sizing

- [ ] 5.3 Migrate general preferences section
  - Stack-based layout for checkboxes and controls
  - Proper spacing using layout guides

- [ ] 5.4 Test window resizing and scaling
  - Verify layout at different window sizes
  - Test with large accessibility text sizes

## 6. Configuration System (P2)

- [ ] 6.1 Create `Configuration.swift`
  - Define nested structs for Hint, Scroll, and Permission configs
  - Load from UserDefaults with sensible defaults
  - Make appearance-related settings observable

- [ ] 6.2 Migrate hardcoded values
  - Move hint characters from PreferencesWindowController
  - Move font sizes from HintView
  - Move scroll amounts from ScrollMode
  - Move poll timeouts from PermissionManager

- [ ] 6.3 Connect Configuration to UI
  - Update PreferencesWindowController to use Configuration
  - Ensure changes are persisted and applied immediately

## 7. Localization Infrastructure (P3)

- [ ] 7.1 Create localization helpers
  - Create `Localizable.strings` template
  - Add `L10n` struct or extension for type-safe string access

- [ ] 7.2 Mark strings for localization
  - Wrap menu item titles with `NSLocalizedString`
  - Wrap alert messages with `NSLocalizedString`
  - Wrap preference labels with `NSLocalizedString`

- [ ] 7.3 Extract English strings
  - Run `genstrings` or equivalent to extract all strings
  - Organize strings by feature/file

## 8. Verification & Documentation

- [ ] 8.1 Run full test suite
  - Ensure all existing tests pass
  - Add new tests for appearance changes
  - Add accessibility audit tests where possible

- [ ] 8.2 Manual testing checklist
  - Test on macOS Ventura (13), Sonoma (14), Sequoia (15)
  - Test with VoiceOver enabled
  - Test Dark Mode switching
  - Test at 200% display scaling

- [ ] 8.3 Update documentation
  - Document new configuration options
  - Update README with accessibility features
  - Add developer notes for appearance handling
