# VoiceOver

## Overview

VoiceOver is Apple's screen reader for blind and low-vision users. Proper support ensures your app is accessible to everyone.

## When to Use

- Any iOS app (accessibility is essential)
- Custom controls and views
- Complex interactive elements
- Media and visual content

## Basic Accessibility Labels

```swift
// SwiftUI
Image(systemName: "star.fill")
    .accessibilityLabel("Favorite")

Button(action: delete) {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete item")

// UIKit
imageView.accessibilityLabel = "Profile photo"
deleteButton.accessibilityLabel = "Delete item"
```

## Accessibility Hints

```swift
// Provide additional context
Button("Submit") { }
    .accessibilityLabel("Submit form")
    .accessibilityHint("Double tap to submit your application")

// UIKit
button.accessibilityHint = "Double tap to submit"
```

## Accessibility Traits

```swift
// SwiftUI
Text("Settings")
    .accessibilityAddTraits(.isHeader)

Button("Play") { }
    .accessibilityAddTraits(.startsMediaSession)

// Common traits
.accessibilityAddTraits(.isButton)
.accessibilityAddTraits(.isLink)
.accessibilityAddTraits(.isHeader)
.accessibilityAddTraits(.isSelected)
.accessibilityAddTraits(.isImage)
.accessibilityAddTraits(.playsSound)
.accessibilityAddTraits(.isSearchField)
.accessibilityAddTraits(.allowsDirectInteraction)

// Remove trait
.accessibilityRemoveTraits(.isImage)
```

## Custom Accessibility Value

```swift
// For controls with changing values
Slider(value: $volume)
    .accessibilityValue("\(Int(volume * 100)) percent")

// Progress
ProgressView(value: progress)
    .accessibilityValue("\(Int(progress * 100)) percent complete")
```

## Grouping Elements

```swift
// Combine multiple elements
HStack {
    Image(systemName: "star.fill")
    Text("5.0")
    Text("(123 reviews)")
}
.accessibilityElement(children: .combine)
// VoiceOver reads: "5.0 (123 reviews)"

// Ignore children, custom label
HStack {
    // Multiple UI elements
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Rating: 5 stars from 123 reviews")
```

## Hide from VoiceOver

```swift
// Decorative elements
Image("decorative-divider")
    .accessibilityHidden(true)

// UIKit
decorativeView.isAccessibilityElement = false
```

## Accessibility Actions

```swift
// Custom actions in VoiceOver rotor
Button("Item") { }
    .accessibilityAction(named: "Delete") {
        deleteItem()
    }
    .accessibilityAction(named: "Share") {
        shareItem()
    }

// Adjustable action (swipe up/down)
Stepper(value: $quantity, in: 1...10) {
    Text("Quantity: \(quantity)")
}
.accessibilityAdjustableAction { direction in
    switch direction {
    case .increment:
        if quantity < 10 { quantity += 1 }
    case .decrement:
        if quantity > 1 { quantity -= 1 }
    @unknown default:
        break
    }
}
```

## Accessibility Focus

```swift
@AccessibilityFocusState private var isFocused: Bool

Text("Important announcement")
    .accessibilityFocused($isFocused)

Button("Announce") {
    isFocused = true  // Move VoiceOver focus here
}
```

## Announcements

```swift
// Post accessibility announcement
UIAccessibility.post(
    notification: .announcement,
    argument: "Download complete"
)

// Screen changed (new view appeared)
UIAccessibility.post(
    notification: .screenChanged,
    argument: titleLabel  // Focus moves here
)

// Layout changed (UI updated)
UIAccessibility.post(
    notification: .layoutChanged,
    argument: nil
)
```

## Custom Accessibility Container

```swift
// UIKit - custom container ordering
class CustomContainer: UIView {
    override var accessibilityElements: [Any]? {
        get {
            return [element1, element2, element3]  // Custom order
        }
        set { }
    }
}
```

## Check VoiceOver Status

```swift
// Check if VoiceOver is running
if UIAccessibility.isVoiceOverRunning {
    // Adapt UI for VoiceOver
}

// Listen for changes
NotificationCenter.default.addObserver(
    forName: UIAccessibility.voiceOverStatusDidChangeNotification,
    object: nil, queue: .main
) { _ in
    // VoiceOver state changed
}
```

## Escape Gesture

```swift
// Handle two-finger Z gesture (dismiss)
override func accessibilityPerformEscape() -> Bool {
    dismiss()
    return true
}
```

## Testing

```swift
// Enable VoiceOver
// Settings → Accessibility → VoiceOver

// Accessibility Inspector
// Xcode → Open Developer Tool → Accessibility Inspector

// Voice Control
// Settings → Accessibility → Voice Control
```

## iOS Version Notes

- iOS 16+: Baseline VoiceOver APIs
- iOS 17+: Enhanced focus management
- iOS 18+: Improved announcements

## Gotchas

1. **Test with VoiceOver ON** - Only way to truly verify
2. **Reading order** - May differ from visual order
3. **Dynamic content** - Post layout changed notifications
4. **Touch exploration** - Elements must have sufficient size
5. **Custom views** - Require manual accessibility implementation

## Related

- [always-on.md](always-on.md) - VoiceOver in Always On state
- [siri.md](siri.md) - Voice-first interface design
