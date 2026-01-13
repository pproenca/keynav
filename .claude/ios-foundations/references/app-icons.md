# App Icons

## Overview

App icons are the visual identity of your app. Apple provides strict guidelines for icon design to ensure consistency across the platform.

## When to Use

- Creating app icon for new project
- Updating existing app icon
- Creating alternate app icons
- Setting up asset catalog

## Design Guidelines

### Shape and Size

- Icons are automatically masked to rounded rectangle (superellipse)
- Design as square, don't add rounded corners
- Single size for Asset Catalog: 1024x1024pt

### Design Principles

```
✓ Simple, recognizable silhouette
✓ Limited color palette (2-3 colors)
✓ No text (illegible at small sizes)
✓ Single focal point
✓ Avoid photos or screenshots
✓ Don't include Apple hardware in icon
```

### Icon Sizes (Reference)

| Context | Size (pt) | Scale |
|---------|-----------|-------|
| App Store | 1024x1024 | 1x |
| iPhone Home | 60x60 | 2x, 3x |
| iPad Home | 76x76 | 2x |
| iPad Pro Home | 83.5x83.5 | 2x |
| Settings | 29x29 | 2x, 3x |
| Spotlight | 40x40 | 2x, 3x |
| Notification | 20x20 | 2x, 3x |

## Asset Catalog Setup

```
Assets.xcassets/
└── AppIcon.appiconset/
    ├── Contents.json
    └── icon_1024.png  (single source)
```

### Contents.json (Single Size - iOS 18+)

```json
{
  "images": [
    {
      "filename": "icon_1024.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

## Alternate App Icons

```swift
// Check if supported
UIApplication.shared.supportsAlternateIcons

// Set alternate icon
UIApplication.shared.setAlternateIconName("IconDark") { error in
    if let error {
        print("Error: \(error)")
    }
}

// Reset to primary
UIApplication.shared.setAlternateIconName(nil)
```

### Asset Catalog for Alternates

```
Assets.xcassets/
├── AppIcon.appiconset/       (primary)
├── IconDark.appiconset/      (alternate)
└── IconPride.appiconset/     (alternate)
```

Also add to Info.plist:

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon</string>
        </array>
    </dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>IconDark</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>IconDark</string>
            </array>
        </dict>
    </dict>
</dict>
```

## Dark Mode Icons (iOS 18+)

```swift
// System automatically switches based on appearance
// Provide dark variant in Asset Catalog:
// AppIcon.appiconset with "Any, Dark" appearances
```

### Asset Catalog Appearances

```json
{
  "images": [
    {
      "filename": "icon_light.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    },
    {
      "appearances": [
        {
          "appearance": "luminosity",
          "value": "dark"
        }
      ],
      "filename": "icon_dark.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
  ]
}
```

## Tinted Icons (iOS 18+)

iOS 18 allows system to apply tint to icons. Design with this in mind:

- Provide high-contrast silhouette
- Test how icon looks with various tint colors
- Avoid relying solely on color for recognition

## Common Export Checklist

```
□ 1024x1024 PNG, no transparency
□ sRGB color space
□ No rounded corners (system applies mask)
□ No alpha channel
□ Tested at small sizes (20pt, 29pt)
□ Readable silhouette without color
```

## iOS Version Notes

- iOS 16+: Single 1024x1024 source supported
- iOS 17+: Symbol-based icons possible
- iOS 18+: Dark mode icons, tinted icons

## Gotchas

1. **No transparency** - Icons must be opaque
2. **Don't add corners** - System applies mask
3. **Test small sizes** - Icons appear at 20pt in notifications
4. **App Store rejection** - Icons with Apple trademarks, misleading imagery
5. **Beta icon** - Remember to remove "beta" badge before release

## Related

- [colors.md](colors.md) - Color palette selection
- [accessibility.md](accessibility.md) - Icon should be recognizable without color
