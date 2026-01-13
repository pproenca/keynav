---
name: ios-inputs
description: |
  iOS input methods and device sensors. Covers gestures (tap, swipe, pinch, rotate,
  long-press, drag), keyboard handling and shortcuts, Apple Pencil with PencilKit and
  Scribble, Action button (iPhone 15 Pro+), Camera Control button, gyroscope and
  accelerometer with CoreMotion, game controllers with GameController framework, focus
  and selection for accessibility and tvOS, nearby interactions, and pointing devices.
  Use this skill when: (1) Implementing touch gestures, (2) Handling keyboard input
  and shortcuts, (3) Supporting Apple Pencil drawing, (4) Using device sensors, (5)
  Supporting game controllers, (6) Implementing accessibility focus, (7) User asks
  about "gesture", "tap", "swipe", "drag", "pinch", "keyboard", "Apple Pencil",
  "PencilKit", "Scribble", "Action button", "gyroscope", "accelerometer", "CoreMotion",
  "game controller", "focus", "nearby interaction".
---

# iOS Inputs

Input methods and device sensors for iOS apps.

## Input Method Decision Tree

```
Primary input type?
├── Touch → Gestures (tap, swipe, pan, pinch, rotate)
├── Stylus → PencilKit or custom drawing
├── Text → Keyboard handling
├── Motion → CoreMotion framework
├── Game → GameController framework
└── Accessibility → Focus system
```

## Quick Start - Gestures

```swift
import SwiftUI

struct GestureDemo: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        Rectangle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = value
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
            )
    }
}
```

## Common Gestures

```swift
// Tap
.onTapGesture {
    handleTap()
}

// Double tap
.onTapGesture(count: 2) {
    handleDoubleTap()
}

// Long press
.onLongPressGesture(minimumDuration: 0.5) {
    handleLongPress()
}

// Drag
.gesture(DragGesture()
    .onChanged { value in }
    .onEnded { value in }
)
```

## Keyboard Shortcuts

```swift
// Button shortcut
Button("Save") { }
    .keyboardShortcut("s", modifiers: .command)

// View-level shortcut
.keyboardShortcut(.defaultAction)  // Return key

// Focus-based shortcut
.focused($isFocused)
.onKeyPress(.return) {
    submit()
    return .handled
}
```

## Reference Files

- **Gestures**: See [references/gestures.md](references/gestures.md) - All gesture types, custom recognizers
- **Keyboard**: See [references/keyboard.md](references/keyboard.md) - Input handling, shortcuts, avoidance
- **Apple Pencil**: See [references/pencil.md](references/pencil.md) - PencilKit, Scribble, pressure/tilt
- **Action Button**: See [references/action-button.md](references/action-button.md) - iPhone 15 Pro+ button
- **Sensors**: See [references/sensors.md](references/sensors.md) - CoreMotion, gyroscope, accelerometer
- **Game Controls**: See [references/game-controls.md](references/game-controls.md) - Controllers, MFi
- **Focus**: See [references/focus-selection.md](references/focus-selection.md) - Accessibility, tvOS patterns

## Common Gotchas

1. **Gesture conflicts** - Use `.simultaneousGesture()` or `.highPriorityGesture()`
2. **Keyboard not dismissing** - Call `UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder)...)`
3. **Pencil vs finger** - Check `UITouch.type` to differentiate
4. **Simulator limitations** - Gyroscope/accelerometer require real device
5. **Focus state persistence** - `@FocusState` resets on view updates
