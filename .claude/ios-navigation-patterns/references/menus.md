# Menus

## Overview

iOS provides context menus (long-press), pull-down menus (button menus), and action sheets for presenting actions.

## When to Use

- Contextual actions on items (context menu)
- Button with multiple options (pull-down menu)
- Destructive confirmations (confirmation dialog)
- System Edit menu integration

## Context Menu

```swift
Text("Long press me")
    .contextMenu {
        Button("Copy", systemImage: "doc.on.doc") {
            copyItem()
        }
        Button("Share", systemImage: "square.and.arrow.up") {
            shareItem()
        }
        Divider()
        Button("Delete", systemImage: "trash", role: .destructive) {
            deleteItem()
        }
    }
```

## Context Menu with Preview

```swift
.contextMenu {
    Button("View") { }
    Button("Edit") { }
} preview: {
    ItemPreviewView(item: item)
        .frame(width: 300, height: 400)
}
```

## Pull-Down Menu (Button Menu)

```swift
Menu {
    Button("Option 1") { }
    Button("Option 2") { }

    Menu("More") {
        Button("Sub-option 1") { }
        Button("Sub-option 2") { }
    }
} label: {
    Label("Options", systemImage: "ellipsis.circle")
}

// Primary action with menu
Menu {
    Button("Secondary") { }
} label: {
    Label("Primary", systemImage: "plus")
} primaryAction: {
    performPrimaryAction()
}
```

## Menu Sections

```swift
Menu {
    Section("Recent") {
        ForEach(recentItems) { item in
            Button(item.name) { select(item) }
        }
    }

    Section("All Items") {
        ForEach(allItems) { item in
            Button(item.name) { select(item) }
        }
    }
} label: {
    Text("Select Item")
}
```

## Picker in Menu

```swift
Menu {
    Picker("Sort By", selection: $sortOrder) {
        Text("Name").tag(SortOrder.name)
        Text("Date").tag(SortOrder.date)
        Text("Size").tag(SortOrder.size)
    }
} label: {
    Label("Sort", systemImage: "arrow.up.arrow.down")
}

// Inline picker (radio-style)
Picker("Sort By", selection: $sortOrder) {
    // ...
}
.pickerStyle(.menu)
```

## Toggle in Menu

```swift
Menu {
    Toggle("Show Hidden", isOn: $showHidden)
    Toggle("Compact View", isOn: $compactView)

    Divider()

    Button("Settings") { }
} label: {
    Image(systemName: "gearshape")
}
```

## Confirmation Dialog (Action Sheet)

```swift
@State private var showConfirmation = false

Button("Delete") {
    showConfirmation = true
}
.confirmationDialog("Delete Item?", isPresented: $showConfirmation, titleVisibility: .visible) {
    Button("Delete", role: .destructive) {
        deleteItem()
    }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("This cannot be undone.")
}
```

## Swipe Actions

```swift
List {
    ForEach(items) { item in
        ItemRow(item: item)
            .swipeActions(edge: .trailing) {
                Button("Delete", role: .destructive) {
                    delete(item)
                }
                Button("Archive") {
                    archive(item)
                }
                .tint(.blue)
            }
            .swipeActions(edge: .leading) {
                Button("Pin") {
                    pin(item)
                }
                .tint(.yellow)
            }
    }
}
```

## Edit Menu (Copy/Paste)

```swift
Text(item.text)
    .textSelection(.enabled)

// Custom edit menu
TextField("Name", text: $name)
    .onCopyCommand {
        [NSItemProvider(object: name as NSString)]
    }
    .onPasteCommand(of: [.plainText]) { providers in
        // Handle paste
    }
```

## Keyboard Shortcuts

```swift
Menu {
    Button("New") { }
        .keyboardShortcut("n", modifiers: .command)

    Button("Open") { }
        .keyboardShortcut("o", modifiers: .command)

    Button("Save") { }
        .keyboardShortcut("s", modifiers: .command)
} label: {
    Text("File")
}
```

## Menu Order

```swift
// System determines order by default
// Force specific order:
Menu {
    Button("First") { }
    Button("Second") { }
}
.menuOrder(.fixed)  // or .priority
```

## iOS Version Notes

- iOS 16+: Baseline menu support
- iOS 17+: Improved menu animations
- iOS 18+: New menu styles

## Gotchas

1. **Context menu vs swipe** - Context for discovery, swipe for quick actions
2. **Destructive actions** - Always use `.destructive` role
3. **Menu depth** - Keep nesting to 2 levels max
4. **Preview performance** - Keep preview view lightweight
5. **iPad hover** - Menus can appear on hover, test behavior

## Related

- [navigation.md](navigation.md) - Toolbar menus
- [undo-redo.md](undo-redo.md) - Edit menu undo/redo
