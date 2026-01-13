# Accessibility

## Overview

iOS accessibility features ensure your app works for everyone. Key areas: VoiceOver, Dynamic Type, color contrast, and motor accessibility.

## When to Use

- Adding accessibility labels to custom views
- Supporting VoiceOver navigation
- Ensuring Dynamic Type support
- Meeting contrast requirements
- Supporting reduced motion

## VoiceOver Labels

```swift
// Basic label
Image(systemName: "star.fill")
    .accessibilityLabel("Favorite")

// Button with action description
Button(action: delete) {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete item")
.accessibilityHint("Double tap to delete this item")

// Custom value
Slider(value: $volume)
    .accessibilityValue("\(Int(volume * 100)) percent")
```

## Accessibility Traits

```swift
// Mark as button (announces "button")
.accessibilityAddTraits(.isButton)

// Mark as header (VoiceOver rotor navigation)
.accessibilityAddTraits(.isHeader)

// Mark as image
.accessibilityAddTraits(.isImage)

// Mark as selected
.accessibilityAddTraits(.isSelected)

// Remove from accessibility tree
.accessibilityHidden(true)
```

## Grouping Elements

```swift
// Group related elements
HStack {
    Image(systemName: "person")
    Text("John Doe")
    Text("Online")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("John Doe, Online")

// Or ignore children and provide custom label
.accessibilityElement(children: .ignore)
.accessibilityLabel("John Doe is currently online")
```

## Dynamic Type Support

```swift
@Environment(\.dynamicTypeSize) var dynamicTypeSize

var body: some View {
    if dynamicTypeSize.isAccessibilitySize {
        // Stack vertically for larger text
        VStack { content }
    } else {
        // Horizontal for normal sizes
        HStack { content }
    }
}

// Limit scaling
Text("Don't scale too much")
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
```

## Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    Circle()
        .animation(reduceMotion ? nil : .spring(), value: isExpanded)
}

// Or use conditional animation
withAnimation(reduceMotion ? nil : .default) {
    isExpanded.toggle()
}
```

## Reduce Transparency

```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency

var body: some View {
    Rectangle()
        .fill(reduceTransparency ? Color(.systemBackground) : .regularMaterial)
}
```

## Color Contrast

```swift
// Check if user enabled increased contrast
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
@Environment(\.accessibilityIncreasedContrast) var increasedContrast

// Don't rely solely on color
HStack {
    Circle()
        .fill(isError ? .red : .green)
    Text(isError ? "Error" : "Success")  // Provide text too
    if differentiateWithoutColor {
        Image(systemName: isError ? "xmark" : "checkmark")  // Add icon
    }
}
```

## Focus Management

```swift
@FocusState private var isFocused: Bool
@AccessibilityFocusState private var accessibilityFocus: Bool

TextField("Name", text: $name)
    .focused($isFocused)
    .accessibilityFocused($accessibilityFocus)

// Move focus programmatically
Button("Focus Name Field") {
    accessibilityFocus = true
}
```

## Accessibility Actions

```swift
// Custom actions in VoiceOver rotor
.accessibilityAction(named: "Mark as Read") {
    markAsRead()
}

// Adjust action (swipe up/down)
.accessibilityAdjustableAction { direction in
    switch direction {
    case .increment: value += 1
    case .decrement: value -= 1
    @unknown default: break
    }
}
```

## Minimum Touch Target

```swift
// Ensure 44x44pt minimum touch area
Button(action: {}) {
    Image(systemName: "xmark")
        .frame(width: 44, height: 44)
}

// Or use contentShape
Image(systemName: "xmark")
    .contentShape(Rectangle().size(width: 44, height: 44))
```

## iOS Version Notes

- iOS 16+: Baseline accessibility APIs
- iOS 17+: New accessibility zoom anchors
- iOS 18+: Improved VoiceOver descriptions

## Gotchas

1. **Test with VoiceOver ON** - Enable in Settings → Accessibility
2. **Don't skip decorative images** - Use `.accessibilityHidden(true)`
3. **Contrast ratio** - 4.5:1 minimum for text, 3:1 for large text/UI
4. **Custom controls need full support** - Labels, traits, values, actions
5. **Test with largest text** - Settings → Accessibility → Larger Text

## Related

- [typography.md](typography.md) - Dynamic Type implementation
- [colors.md](colors.md) - Color contrast and semantic colors
