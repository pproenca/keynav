# Navigation

## Overview

iOS navigation uses NavigationStack for hierarchical content and NavigationSplitView for master-detail layouts. Value-based navigation enables deep linking and state restoration.

## When to Use

- Building hierarchical navigation flows
- Implementing deep linking
- Managing complex navigation state
- Supporting iPad split views

## NavigationStack Basics

```swift
// Simple navigation
NavigationStack {
    List(items) { item in
        NavigationLink(item.name, value: item)
    }
    .navigationDestination(for: Item.self) { item in
        ItemDetailView(item: item)
    }
}

// Navigation bar configuration
.navigationTitle("Items")
.navigationBarTitleDisplayMode(.large)  // .large, .inline, .automatic

// Toolbar items
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button("Add", systemImage: "plus") { }
    }
    ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { }
    }
}
```

## Path-Based Navigation

```swift
// Codable path for state restoration
@State private var path = NavigationPath()

NavigationStack(path: $path) {
    HomeView()
        .navigationDestination(for: Item.self) { item in
            ItemDetailView(item: item)
        }
        .navigationDestination(for: Category.self) { category in
            CategoryView(category: category)
        }
}

// Programmatic navigation
func navigateToItem(_ item: Item) {
    path.append(item)
}

func popToRoot() {
    path = NavigationPath()
}

func goBack() {
    if !path.isEmpty {
        path.removeLast()
    }
}
```

## Deep Linking

```swift
// URL scheme: myapp://item/123
struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Item.self) { item in
                    ItemDetailView(item: item)
                }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "myapp" else { return }

        switch url.host {
        case "item":
            if let id = url.pathComponents.last,
               let item = fetchItem(id: id) {
                path = NavigationPath()  // Reset
                path.append(item)
            }
        default:
            break
        }
    }
}
```

## State Restoration

```swift
// Persist navigation state
@SceneStorage("navigationPath") private var pathData: Data?

var body: some View {
    NavigationStack(path: $path) {
        // ...
    }
    .task {
        // Restore
        if let data = pathData {
            path = try? JSONDecoder().decode(NavigationPath.self, from: data)
        }
    }
    .onChange(of: path) { _, newPath in
        // Save
        pathData = try? JSONEncoder().encode(newPath)
    }
}
```

## NavigationSplitView

```swift
// Two-column (sidebar + detail)
@State private var selectedItem: Item?
@State private var columnVisibility = NavigationSplitViewVisibility.all

NavigationSplitView(columnVisibility: $columnVisibility) {
    List(items, selection: $selectedItem) { item in
        NavigationLink(value: item) {
            ItemRow(item: item)
        }
    }
    .navigationTitle("Items")
} detail: {
    if let item = selectedItem {
        ItemDetailView(item: item)
    } else {
        ContentUnavailableView("Select an Item",
            systemImage: "square.dashed",
            description: Text("Choose from the sidebar"))
    }
}
.navigationSplitViewStyle(.balanced)  // or .prominentDetail
```

## Toolbar Placements

```swift
.toolbar {
    // Navigation bar leading
    ToolbarItem(placement: .topBarLeading) { }

    // Navigation bar trailing
    ToolbarItem(placement: .topBarTrailing) { }

    // Primary action (trailing, prominent)
    ToolbarItem(placement: .primaryAction) { }

    // Cancellation (leading)
    ToolbarItem(placement: .cancellationAction) { }

    // Bottom bar
    ToolbarItem(placement: .bottomBar) { }

    // Keyboard above
    ToolbarItem(placement: .keyboard) { }
}

// Hide toolbar
.toolbar(.hidden, for: .navigationBar)
.toolbarBackground(.visible, for: .navigationBar)
.toolbarColorScheme(.dark, for: .navigationBar)
```

## iOS Version Notes

- iOS 16+: NavigationStack, NavigationSplitView, value-based navigation
- iOS 17+: Improved navigation animations, inspector
- iOS 18+: New tab bar customization

## Gotchas

1. **Don't nest NavigationStacks** - One per navigation context
2. **NavigationLink in lazy containers** - Use value-based, not destination
3. **Path encoding** - Types must be Hashable and Codable for state restoration
4. **Split view on iPhone** - Collapses to stack; test both layouts
5. **Toolbar in sheets** - Use `.presentationDetents` and sheet-specific toolbar

## Related

- [modals.md](modals.md) - Sheet and popover presentations
- [search.md](search.md) - Search in navigation bars
