# Colors

## Overview

iOS provides semantic color system that automatically adapts to Dark Mode, accessibility settings, and device traits.

## When to Use

- Setting up app color scheme
- Implementing Dark Mode support
- Creating custom colors that adapt
- Using tint colors and accent colors

## Semantic Colors (SwiftUI)

```swift
// Text colors
Text("Primary").foregroundStyle(.primary)
Text("Secondary").foregroundStyle(.secondary)
Text("Tertiary").foregroundStyle(.tertiary)
Text("Quaternary").foregroundStyle(.quaternary)

// Background colors
.background(Color(.systemBackground))
.background(Color(.secondarySystemBackground))
.background(Color(.tertiarySystemBackground))

// Grouped backgrounds (for grouped table views)
.background(Color(.systemGroupedBackground))
.background(Color(.secondarySystemGroupedBackground))
```

## System Colors

```swift
// Standard system colors (adapt to light/dark)
Color.red       // systemRed
Color.orange    // systemOrange
Color.yellow    // systemYellow
Color.green     // systemGreen
Color.mint      // systemMint (iOS 15+)
Color.teal      // systemTeal
Color.cyan      // systemCyan
Color.blue      // systemBlue
Color.indigo    // systemIndigo
Color.purple    // systemPurple
Color.pink      // systemPink
Color.brown     // systemBrown
Color.gray      // systemGray
```

## Gray Scale

```swift
// Six gray levels that adapt to appearance
Color(.systemGray)
Color(.systemGray2)
Color(.systemGray3)
Color(.systemGray4)
Color(.systemGray5)
Color(.systemGray6)
```

## App Tint/Accent Color

```swift
// Set in Asset Catalog as "AccentColor"
// Or programmatically:
.tint(.blue)

// Access current tint
@Environment(\.tint) var tint
```

## Custom Adaptive Colors

```swift
// In Asset Catalog: Create Color Set with Any/Dark appearances

// Code-based adaptive color
extension Color {
    static let customBackground = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
                : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        }
    )
}
```

## Color Scheme Detection

```swift
@Environment(\.colorScheme) var colorScheme

var body: some View {
    Text("Hello")
        .foregroundStyle(colorScheme == .dark ? .white : .black)
}

// Force specific appearance
.preferredColorScheme(.dark)
.preferredColorScheme(.light)
```

## Materials (Blur Effects)

```swift
// Liquid Glass materials
.background(.ultraThinMaterial)
.background(.thinMaterial)
.background(.regularMaterial)
.background(.thickMaterial)
.background(.ultraThickMaterial)
.background(.bar)  // Navigation/Tab bar style
```

## Gradients

```swift
// Linear gradient
LinearGradient(
    colors: [.blue, .purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// Angular gradient
AngularGradient(
    colors: [.red, .yellow, .green, .blue, .purple, .red],
    center: .center
)

// Radial gradient
RadialGradient(
    colors: [.white, .black],
    center: .center,
    startRadius: 0,
    endRadius: 200
)
```

## iOS Version Notes

- iOS 16+: Baseline semantic colors
- iOS 17+: New `.foregroundStyle()` shader support
- iOS 18+: Improved material performance

## Gotchas

1. **Never hardcode RGB values** - Use semantic colors or Asset Catalog
2. **Test in both modes** - Always verify Dark Mode appearance
3. **Contrast requirements** - 4.5:1 for normal text, 3:1 for large text
4. **Avoid pure black/white** - Can be harsh; use `.primary` and `.systemBackground`

## Related

- [accessibility.md](accessibility.md) - Color contrast requirements
- [typography.md](typography.md) - Text color styling
