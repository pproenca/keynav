---
name: ios-foundations
description: |
  Core iOS design foundations from Apple's Human Interface Guidelines. Covers design
  principles (clarity, consistency, deference, depth), the Liquid Glass design system
  (iOS 26+), typography with San Francisco font and Dynamic Type, color system with
  semantic colors and Dark Mode, accessibility requirements (VoiceOver, contrast,
  Dynamic Type), layout with Safe Areas and adaptive design, and app icon guidelines.
  Use this skill when: (1) Starting any iOS project, (2) Reviewing designs for HIG
  compliance, (3) Implementing visual design systems, (4) Setting up app theming and
  Dark Mode, (5) Ensuring accessibility compliance, (6) Creating app icons, (7) User
  asks about "iOS design", "HIG", "Human Interface Guidelines", "Apple design",
  "SwiftUI styling", "Dark Mode", "accessibility iOS", "Dynamic Type", "Safe Area",
  "SF Symbols", "system colors".
---

# iOS Foundations

Core design principles and visual foundations for iOS apps following Apple's Human Interface Guidelines.

## Design Principles

### The Four Pillars

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Clarity** | Content is paramount | Remove visual clutter, use whitespace, clear typography |
| **Consistency** | Familiar patterns | Use system components, follow platform conventions |
| **Deference** | UI serves content | Subtle chrome, content-first hierarchy |
| **Depth** | Visual layers guide focus | Meaningful motion, layered materials |

### Quick Decision Guide

```
Is the UI element necessary?
├── No → Remove it
└── Yes → Does it follow system patterns?
    ├── No → Consider system alternative
    └── Yes → Does it compete with content?
        ├── Yes → Reduce visual weight
        └── No → Ship it
```

## Liquid Glass (iOS 26+)

Apple's 2025 design language emphasizing translucency and depth.

```swift
// Liquid Glass material
.background(.ultraThinMaterial)
.background(.regularMaterial)
.background(.thickMaterial)

// Glass-like container
RoundedRectangle(cornerRadius: 20)
    .fill(.ultraThinMaterial)
    .shadow(radius: 10)
```

**Key characteristics:**
- Translucent surfaces that adapt to content beneath
- Dynamic light response
- Rounded corners (16-24pt radius typical)
- Subtle shadows for depth

## Quick Start

```swift
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, iOS!")
                .font(.largeTitle)      // System font, Dynamic Type
                .foregroundStyle(.primary)  // Semantic color

            Text("Subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)   // Liquid Glass
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

## Reference Files

- **Typography**: See [references/typography.md](references/typography.md) - San Francisco, Dynamic Type, text styles
- **Colors**: See [references/colors.md](references/colors.md) - System colors, semantic colors, Dark Mode
- **Accessibility**: See [references/accessibility.md](references/accessibility.md) - VoiceOver, Dynamic Type, contrast
- **Layout**: See [references/layout.md](references/layout.md) - Safe Areas, adaptive layout, Size Classes
- **App Icons**: See [references/app-icons.md](references/app-icons.md) - Design specs, asset catalog setup

## Common Gotchas

1. **Hardcoded colors** - Always use semantic colors (`.primary`, `.secondary`, `Color(.systemBackground)`) for Dark Mode support
2. **Fixed font sizes** - Use `.font(.body)` etc. for Dynamic Type support, never hardcoded points
3. **Ignoring Safe Areas** - Always respect `safeAreaInsets` for notch and home indicator
4. **Custom when system exists** - Use system components (alerts, sheets, pickers) before custom
5. **Missing accessibility labels** - Every interactive element needs `.accessibilityLabel()`
