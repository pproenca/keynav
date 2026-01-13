---
name: ios-navigation-patterns
description: |
  iOS navigation and presentation patterns from Apple's Human Interface Guidelines.
  Covers NavigationStack and NavigationSplitView, tab bars with TabView, search
  implementation with searchable modifier, modal presentations (sheets, full screen,
  popovers), undo/redo with UndoManager, context menus and pull-down menus, and screen
  transitions. Use this skill when: (1) Designing app navigation structure, (2)
  Implementing tab bars or navigation stacks, (3) Adding search functionality, (4)
  Creating modal presentations and sheets, (5) Implementing undo/redo, (6) Building
  context menus or action sheets, (7) User asks about "navigation", "tab bar",
  "NavigationStack", "NavigationSplitView", "sheet", "modal", "popover", "search bar",
  "searchable", "undo", "redo", "context menu", "menu", "action sheet", "deep linking".
---

# iOS Navigation Patterns

Navigation architecture and presentation patterns for iOS apps.

## Navigation Architecture Decision Tree

```
App has 2-5 top-level sections?
├── Yes → TabView with NavigationStack per tab
└── No → Single NavigationStack or NavigationSplitView

Need master-detail layout?
├── Yes → NavigationSplitView
└── No → NavigationStack

Showing temporary content?
├── Yes → Sheet or fullScreenCover
└── No → NavigationStack push
```

## Quick Start

```swift
import SwiftUI

// Tab-based app with navigation
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}
```

## NavigationStack (iOS 16+)

```swift
// Value-based navigation (recommended)
@State private var path = NavigationPath()

NavigationStack(path: $path) {
    List(items) { item in
        NavigationLink(value: item) {
            Text(item.name)
        }
    }
    .navigationDestination(for: Item.self) { item in
        ItemDetailView(item: item)
    }
    .navigationTitle("Items")
}

// Programmatic navigation
Button("Go to Item") {
    path.append(selectedItem)
}

// Pop to root
Button("Home") {
    path.removeLast(path.count)
}
```

## NavigationSplitView (iPad + Mac)

```swift
@State private var selectedItem: Item?

NavigationSplitView {
    // Sidebar
    List(items, selection: $selectedItem) { item in
        Text(item.name)
    }
    .navigationTitle("Items")
} detail: {
    // Detail
    if let item = selectedItem {
        ItemDetailView(item: item)
    } else {
        Text("Select an item")
    }
}

// Three-column
NavigationSplitView {
    SidebarView()
} content: {
    ContentListView()
} detail: {
    DetailView()
}
```

## Reference Files

- **Navigation**: See [references/navigation.md](references/navigation.md) - Deep navigation patterns, deep linking
- **Search**: See [references/search.md](references/search.md) - Searchable, suggestions, scopes
- **Modals**: See [references/modals.md](references/modals.md) - Sheets, detents, popovers, alerts
- **Undo/Redo**: See [references/undo-redo.md](references/undo-redo.md) - UndoManager integration
- **Menus**: See [references/menus.md](references/menus.md) - Context menus, pull-down menus, actions

## Common Gotchas

1. **NavigationLink in List** - Use value-based navigation, not destination closure
2. **Sheet vs fullScreenCover** - Sheets can be dismissed by swipe; fullScreenCover requires explicit dismiss
3. **TabView badge disappears** - Badge resets on tab change; persist in state
4. **Deep link handling** - Must update navigation path, not just deepest view
5. **iPad navigation** - Test split view behavior in all size classes
