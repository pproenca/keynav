# Layout

## Overview

iOS layout system handles Safe Areas, adaptive sizing with Size Classes, and responsive design across all iPhone and iPad models.

## When to Use

- Setting up app structure and containers
- Handling Safe Areas (notch, Dynamic Island, home indicator)
- Building adaptive layouts for different devices
- Implementing scroll views and lists

## Safe Areas

```swift
// Automatic Safe Area handling (default)
VStack {
    Text("Content respects Safe Areas by default")
}

// Ignore Safe Areas
VStack {
    Image("header")
        .ignoresSafeArea(.all, edges: .top)

    Text("Content")
}

// Read Safe Area insets
GeometryReader { geometry in
    let insets = geometry.safeAreaInsets
    Text("Top: \(insets.top), Bottom: \(insets.bottom)")
}
```

## Size Classes

```swift
@Environment(\.horizontalSizeClass) var horizontalSizeClass
@Environment(\.verticalSizeClass) var verticalSizeClass

var body: some View {
    if horizontalSizeClass == .compact {
        // iPhone portrait, iPad slide-over
        VStack { content }
    } else {
        // iPad, iPhone landscape
        HStack { content }
    }
}
```

### Device Size Class Matrix

| Device | Portrait | Landscape |
|--------|----------|-----------|
| iPhone | compact/regular | compact/compact |
| iPhone Plus/Max | compact/regular | regular/compact |
| iPad | regular/regular | regular/regular |
| iPad Split View | compact or regular/regular | depends on split |

## Adaptive Stacks

```swift
// ViewThatFits - picks first that fits
ViewThatFits {
    HStack { content }  // Tries this first
    VStack { content }  // Falls back to this
}

// Grid for adaptive columns
LazyVGrid(columns: [
    GridItem(.adaptive(minimum: 100, maximum: 200))
]) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## GeometryReader

```swift
// Read available size
GeometryReader { geometry in
    let width = geometry.size.width
    let height = geometry.size.height

    Circle()
        .frame(width: min(width, height) * 0.8)
}

// Coordinate spaces
GeometryReader { geometry in
    let localFrame = geometry.frame(in: .local)
    let globalFrame = geometry.frame(in: .global)
    let namedFrame = geometry.frame(in: .named("container"))
}
.coordinateSpace(name: "container")
```

## Spacing and Padding

```swift
// System spacing (adapts to platform)
VStack(spacing: nil) { }  // Uses system default (~8pt)

// Edge-specific padding
.padding(.horizontal, 16)
.padding(.vertical, 8)
.padding(.top, 20)

// Content margins (iOS 17+)
.contentMargins(.horizontal, 20, for: .scrollContent)
```

## ScrollView

```swift
// Basic scroll view
ScrollView {
    LazyVStack {
        ForEach(items) { ItemView(item: $0) }
    }
}

// Scroll indicators
ScrollView(showsIndicators: false) { }

// Scroll position (iOS 17+)
@State private var scrollPosition: Int?

ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemView(item: item)
                .id(item.id)
        }
    }
    .scrollTargetLayout()
}
.scrollPosition(id: $scrollPosition)
```

## List Layout

```swift
// Standard list
List(items) { item in
    Text(item.name)
}

// List styles
.listStyle(.plain)
.listStyle(.insetGrouped)
.listStyle(.sidebar)

// Custom row insets
.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

// Remove separators
.listRowSeparator(.hidden)
```

## Frame Alignment

```swift
// Explicit frame
.frame(width: 100, height: 100)

// Flexible frame
.frame(maxWidth: .infinity, alignment: .leading)
.frame(minHeight: 44)

// Ideal size
.frame(idealWidth: 300)
.fixedSize(horizontal: true, vertical: false)
```

## ZStack and Overlay

```swift
// Layered content
ZStack(alignment: .bottomTrailing) {
    Image("photo")
    Text("Badge")
        .padding(8)
        .background(.red)
}

// Overlay modifier
Image("photo")
    .overlay(alignment: .bottomTrailing) {
        Text("Badge")
    }
    .background {
        Color.gray  // Behind image
    }
```

## iOS Version Notes

- iOS 16+: Baseline layout system
- iOS 17+: `scrollPosition`, `contentMargins`, improved animation
- iOS 18+: New zoom transitions

## Gotchas

1. **GeometryReader takes all space** - Use sparingly, affects parent sizing
2. **Safe Area defaults are good** - Only ignore when intentional
3. **Test all orientations** - Portrait, landscape, multitasking
4. **iPad keyboard** - Layouts shift when keyboard appears
5. **Dynamic Island** - Content shouldn't be obscured

## Related

- [accessibility.md](accessibility.md) - Dynamic Type layout considerations
- [typography.md](typography.md) - Text layout and truncation
