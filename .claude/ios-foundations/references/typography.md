# Typography

## Overview

iOS uses San Francisco (SF Pro) as the system font. Always use system text styles for automatic Dynamic Type support.

## When to Use

- Setting up text hierarchy in your app
- Implementing Dynamic Type accessibility
- Customizing fonts while maintaining system behavior

## Text Styles

```swift
// Standard text styles (Dynamic Type enabled)
Text("Large Title").font(.largeTitle)      // 34pt
Text("Title").font(.title)                  // 28pt
Text("Title 2").font(.title2)              // 22pt
Text("Title 3").font(.title3)              // 20pt
Text("Headline").font(.headline)           // 17pt semibold
Text("Body").font(.body)                   // 17pt
Text("Callout").font(.callout)             // 16pt
Text("Subheadline").font(.subheadline)     // 15pt
Text("Footnote").font(.footnote)           // 13pt
Text("Caption").font(.caption)             // 12pt
Text("Caption 2").font(.caption2)          // 11pt
```

## Dynamic Type

```swift
// Respect user's text size preference
@Environment(\.dynamicTypeSize) var dynamicTypeSize

// Limit scaling for specific elements
Text("Fixed max size")
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)

// Check for accessibility sizes
if dynamicTypeSize.isAccessibilitySize {
    // Use vertical layout instead of horizontal
}
```

## Custom Fonts with Dynamic Type

```swift
// Custom font that scales with Dynamic Type
Text("Custom")
    .font(.custom("Avenir-Medium", size: 17, relativeTo: .body))

// UIKit equivalent
let customFont = UIFont(name: "Avenir-Medium", size: 17)!
let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: customFont)
```

## Font Weight and Design

```swift
// Weight variations
Text("Bold").fontWeight(.bold)
Text("Semibold").fontWeight(.semibold)
Text("Regular").fontWeight(.regular)
Text("Light").fontWeight(.light)

// Design variations
Text("Rounded").fontDesign(.rounded)
Text("Monospaced").fontDesign(.monospaced)
Text("Serif").fontDesign(.serif)
```

## SF Symbols in Text

```swift
// Inline symbols scale with text
Label("Settings", systemImage: "gear")

Text("Download \(Image(systemName: "arrow.down.circle")) now")

// Symbol rendering modes
Image(systemName: "heart.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.red)
```

## iOS Version Notes

- iOS 16+: Baseline support
- iOS 17+: New `fontWidth` modifier for variable width
- iOS 18+: Improved Dynamic Type animations

## Gotchas

1. **Never use hardcoded point sizes** - Breaks accessibility
2. **Test with largest Dynamic Type** - Settings → Accessibility → Larger Text
3. **Truncation handling** - Use `.lineLimit()` and `.truncationMode()` intentionally
4. **Custom fonts need metrics** - Always use `UIFontMetrics` for scaling

## Related

- [colors.md](colors.md) - Text colors and styling
- [accessibility.md](accessibility.md) - Dynamic Type accessibility requirements
