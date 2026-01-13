# Search

## Overview

iOS provides the `.searchable` modifier for integrated search experiences with suggestions, scopes, and tokens.

## When to Use

- Adding search to lists or collections
- Implementing search suggestions
- Creating filtered views
- Building search with scopes (categories)

## Basic Search

```swift
struct SearchableList: View {
    @State private var searchText = ""
    let items: [Item]

    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredItems) { item in
                Text(item.name)
            }
            .searchable(text: $searchText, prompt: "Search items")
            .navigationTitle("Items")
        }
    }
}
```

## Search Placement

```swift
// In navigation bar (default)
.searchable(text: $searchText, placement: .navigationBarDrawer)

// Always visible
.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))

// Sidebar (iPad)
.searchable(text: $searchText, placement: .sidebar)

// Toolbar
.searchable(text: $searchText, placement: .toolbar)
```

## Search Suggestions

```swift
.searchable(text: $searchText) {
    ForEach(suggestions) { suggestion in
        Text(suggestion.name)
            .searchCompletion(suggestion.name)
    }
}

// With icons
.searchable(text: $searchText) {
    ForEach(recentSearches) { search in
        Label(search, systemImage: "clock")
            .searchCompletion(search)
    }

    ForEach(trendingSearches) { search in
        Label(search, systemImage: "arrow.up.right")
            .searchCompletion(search)
    }
}
```

## Search Scopes

```swift
enum SearchScope: String, CaseIterable {
    case all = "All"
    case documents = "Documents"
    case photos = "Photos"
}

@State private var searchScope = SearchScope.all

.searchable(text: $searchText)
.searchScopes($searchScope) {
    ForEach(SearchScope.allCases, id: \.self) { scope in
        Text(scope.rawValue).tag(scope)
    }
}
```

## Search Tokens

```swift
struct SearchToken: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
}

@State private var searchTokens: [SearchToken] = []

.searchable(text: $searchText, tokens: $searchTokens) { token in
    Label(token.name, systemImage: token.icon)
}

// Add token from suggestion
.searchable(text: $searchText, tokens: $searchTokens) { token in
    Label(token.name, systemImage: token.icon)
} suggestions: {
    ForEach(suggestedTokens) { token in
        Label(token.name, systemImage: token.icon)
            .searchCompletion(token)
    }
}
```

## Search State

```swift
@Environment(\.isSearching) var isSearching
@Environment(\.dismissSearch) var dismissSearch

var body: some View {
    List {
        if isSearching {
            // Show search results UI
        } else {
            // Show normal content
        }
    }
}

// Dismiss programmatically
Button("Done") {
    dismissSearch()
}
```

## Search Submit

```swift
.searchable(text: $searchText)
.onSubmit(of: .search) {
    performSearch(searchText)
}
```

## Async Search

```swift
@State private var searchTask: Task<Void, Never>?

.searchable(text: $searchText)
.onChange(of: searchText) { _, newValue in
    searchTask?.cancel()
    searchTask = Task {
        try? await Task.sleep(for: .milliseconds(300))  // Debounce
        guard !Task.isCancelled else { return }
        await performSearch(newValue)
    }
}
```

## iOS Version Notes

- iOS 16+: Baseline searchable API
- iOS 17+: Search tokens, improved suggestions
- iOS 18+: Search in Tab Bar

## Gotchas

1. **Debounce searches** - Don't search on every keystroke
2. **Empty state** - Show helpful message when no results
3. **Cancel search** - Ensure dismiss works properly
4. **Suggestions performance** - Limit suggestion count
5. **Keyboard handling** - Test with hardware keyboard on iPad

## Related

- [navigation.md](navigation.md) - Search in navigation context
- [menus.md](menus.md) - Filter menus as search alternative
