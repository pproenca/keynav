# Gestures

## Overview

SwiftUI provides built-in gesture recognizers for common interactions. Custom gestures can be composed from primitives.

## When to Use

- Implementing touch interactions
- Building custom controls
- Creating interactive animations
- Handling multi-touch input

## Built-in Gestures

```swift
// Tap gesture
.onTapGesture {
    print("Tapped")
}

// Multi-tap
.onTapGesture(count: 2) {
    print("Double tapped")
}

// Long press
.onLongPressGesture(minimumDuration: 0.5) {
    print("Long pressed")
} onPressingChanged: { isPressing in
    print("Pressing: \(isPressing)")
}

// Drag (pan)
.gesture(DragGesture()
    .onChanged { value in
        offset = value.translation
    }
    .onEnded { value in
        offset = .zero
    }
)
```

## Transform Gestures

```swift
// Magnification (pinch)
@State private var scale: CGFloat = 1.0

.gesture(MagnificationGesture()
    .onChanged { value in
        scale = value
    }
    .onEnded { _ in
        scale = 1.0
    }
)
.scaleEffect(scale)

// Rotation
@State private var angle: Angle = .zero

.gesture(RotationGesture()
    .onChanged { value in
        angle = value
    }
)
.rotationEffect(angle)
```

## Gesture Composition

```swift
// Simultaneous gestures (both active)
.gesture(
    DragGesture()
        .simultaneously(with: MagnificationGesture())
)

// Sequenced gestures (one after another)
.gesture(
    LongPressGesture()
        .sequenced(before: DragGesture())
        .onEnded { value in
            switch value {
            case .first(true):
                print("Long press completed")
            case .second(true, let drag):
                print("Dragged after long press")
            default:
                break
            }
        }
)

// Exclusive gestures (highest priority wins)
.gesture(
    TapGesture(count: 2)
        .exclusively(before: TapGesture(count: 1))
)
```

## Gesture Priority

```swift
// High priority (overrides children)
.highPriorityGesture(
    DragGesture()
)

// Simultaneous (both parent and child)
.simultaneousGesture(
    TapGesture()
)
```

## Gesture State

```swift
@GestureState private var isDragging = false
@State private var offset: CGSize = .zero

.gesture(
    DragGesture()
        .updating($isDragging) { _, state, _ in
            state = true  // Resets when gesture ends
        }
        .onChanged { value in
            offset = value.translation
        }
)
.scaleEffect(isDragging ? 1.1 : 1.0)
```

## Spatial Tap Gesture (iOS 16+)

```swift
.onTapGesture { location in
    print("Tapped at: \(location)")
}

// In specific coordinate space
.onTapGesture(coordinateSpace: .global) { location in
    print("Global location: \(location)")
}
```

## Custom Gesture Recognizer (UIKit)

```swift
class CustomGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        // Start tracking
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        // Update
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .recognized
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}

// Use in SwiftUI
struct GestureView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gesture = CustomGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture))
        view.addGestureRecognizer(gesture)
        return view
    }
}
```

## Gesture Velocity

```swift
.gesture(
    DragGesture()
        .onEnded { value in
            let velocity = value.predictedEndLocation
            // Use for momentum/fling
        }
)
```

## iOS Version Notes

- iOS 16+: Spatial tap gesture with location
- iOS 17+: Improved gesture animations
- iOS 18+: Enhanced multi-touch

## Gotchas

1. **Gesture conflicts in ScrollView** - ScrollView consumes drag gestures
2. **Minimum distance** - DragGesture has default minimum; set `.minimumDistance(0)` for immediate response
3. **State reset** - `@GestureState` auto-resets; use `@State` for persistence
4. **Coordinate spaces** - Be aware of local vs global coordinates
5. **Simultaneous recognition** - Must explicitly enable for multiple gestures

## Related

- [pencil.md](pencil.md) - Apple Pencil gestures
- [focus-selection.md](focus-selection.md) - Keyboard and focus navigation
