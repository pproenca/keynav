# Focus and Selection

## Overview

iOS focus system manages keyboard navigation, accessibility focus (VoiceOver), and tvOS-style focus for controllers.

## When to Use

- Managing keyboard/tab navigation
- Supporting VoiceOver navigation
- Building tvOS apps with focus
- Creating accessible custom controls

## SwiftUI Focus State

```swift
enum Field: Hashable {
    case username
    case password
    case submit
}

@FocusState private var focusedField: Field?

var body: some View {
    VStack {
        TextField("Username", text: $username)
            .focused($focusedField, equals: .username)

        SecureField("Password", text: $password)
            .focused($focusedField, equals: .password)

        Button("Submit") { submit() }
            .focused($focusedField, equals: .submit)
    }
    .onAppear {
        focusedField = .username
    }
}
```

## Boolean Focus State

```swift
@FocusState private var isSearchFocused: Bool

TextField("Search", text: $query)
    .focused($isSearchFocused)

Button("Search") {
    isSearchFocused = false  // Dismiss keyboard
    performSearch()
}
```

## Submit Handler with Focus

```swift
TextField("Username", text: $username)
    .focused($focusedField, equals: .username)
    .submitLabel(.next)
    .onSubmit {
        focusedField = .password
    }

SecureField("Password", text: $password)
    .focused($focusedField, equals: .password)
    .submitLabel(.done)
    .onSubmit {
        focusedField = nil
        login()
    }
```

## Accessibility Focus

```swift
@AccessibilityFocusState private var isAnnouncing: Bool

VStack {
    Text("Important message")
        .accessibilityFocused($isAnnouncing)

    Button("Announce") {
        isAnnouncing = true  // VoiceOver focuses here
    }
}
```

## Focusable Modifier

```swift
// Make custom view focusable
struct FocusableCard: View {
    @FocusState private var isFocused: Bool

    var body: some View {
        CardContent()
            .focusable()
            .focused($isFocused)
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .animation(.spring(), value: isFocused)
    }
}
```

## Focus Section (tvOS)

```swift
// Group related focusable items
FocusSection {
    HStack {
        Button("Option 1") { }
        Button("Option 2") { }
        Button("Option 3") { }
    }
}
```

## Default Focus

```swift
// Set initial focus
NavigationStack {
    Form {
        TextField("Name", text: $name)
        TextField("Email", text: $email)
    }
}
.defaultFocus($focusedField, .name)
```

## Focus Navigation

```swift
// Control focus movement
.focusScope(namespace)

// Focus effects
.focusEffectDisabled()

// tvOS specific
.focusable(true, interactions: .edit)
```

## Keyboard Navigation (Mac Catalyst/iPad)

```swift
// Enable arrow key navigation
List(items, id: \.id, selection: $selectedItem) { item in
    Text(item.name)
}
.focusable()

// Handle key events
.onKeyPress(.upArrow) {
    moveSelectionUp()
    return .handled
}
.onKeyPress(.downArrow) {
    moveSelectionDown()
    return .handled
}
```

## Custom Focusable Control

```swift
struct CustomSlider: View {
    @Binding var value: Double
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text("\(Int(value))")
            Slider(value: $value)
        }
        .padding()
        .background(isFocused ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .focusable()
        .focused($isFocused)
        .onKeyPress(.leftArrow) {
            value = max(0, value - 1)
            return .handled
        }
        .onKeyPress(.rightArrow) {
            value = min(100, value + 1)
            return .handled
        }
    }
}
```

## UIKit Focus System

```swift
class FocusableViewController: UIViewController {
    override var canBecomeFocused: Bool { true }

    override func didUpdateFocus(
        in context: UIFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator
    ) {
        if context.nextFocusedView == self.view {
            coordinator.addCoordinatedAnimations {
                self.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        } else if context.previouslyFocusedView == self.view {
            coordinator.addCoordinatedAnimations {
                self.view.transform = .identity
            }
        }
    }
}
```

## iOS Version Notes

- iOS 16+: @FocusState, focusable modifier
- iOS 17+: @AccessibilityFocusState, onKeyPress
- tvOS: Full focus-based navigation

## Gotchas

1. **Focus state resets** - @FocusState resets on view recreation
2. **Keyboard must be visible** - Focus only works with keyboard shown
3. **VoiceOver interaction** - Test with VoiceOver enabled
4. **Multiple focus states** - Only one can be true at a time
5. **tvOS testing** - Focus system works differently; test on device/simulator

## Related

- [keyboard.md](keyboard.md) - Keyboard shortcuts and input
- [gestures.md](gestures.md) - Touch-based selection
