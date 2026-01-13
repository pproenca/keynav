# Modals

## Overview

iOS offers sheets, full screen covers, popovers, and alerts for presenting content over the current context.

## When to Use

- Showing temporary content or workflows
- Collecting user input (forms, settings)
- Displaying alerts and confirmations
- iPad/Mac popovers for contextual content

## Sheets

```swift
@State private var showSheet = false

Button("Show Sheet") {
    showSheet = true
}
.sheet(isPresented: $showSheet) {
    SheetContent()
}

// With item binding
@State private var selectedItem: Item?

.sheet(item: $selectedItem) { item in
    ItemDetailView(item: item)
}
```

## Sheet Detents (iOS 16+)

```swift
.sheet(isPresented: $showSheet) {
    SheetContent()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// Custom height
.presentationDetents([
    .height(200),
    .fraction(0.6),
    .medium,
    .large
])

// Background interaction
.presentationBackgroundInteraction(.enabled(upThrough: .medium))

// Prevent dismissal at certain detent
.interactiveDismissDisabled(currentDetent == .large)
```

## Sheet Customization

```swift
.sheet(isPresented: $showSheet) {
    SheetContent()
        // Appearance
        .presentationCornerRadius(20)
        .presentationBackground(.ultraThinMaterial)

        // Behavior
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()

        // Sizing
        .presentationDetents([.medium])
        .presentationContentInteraction(.scrolls)
}
```

## Full Screen Cover

```swift
@State private var showFullScreen = false

.fullScreenCover(isPresented: $showFullScreen) {
    NavigationStack {
        FullScreenContent()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        showFullScreen = false
                    }
                }
            }
    }
}
```

## Dismissing Sheets

```swift
@Environment(\.dismiss) var dismiss

struct SheetContent: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Sheet Content")
            Button("Done") {
                dismiss()
            }
        }
    }
}

// Prevent swipe dismiss
.interactiveDismissDisabled()

// Confirm before dismiss
.interactiveDismissDisabled(!canDismiss)
```

## Popovers

```swift
@State private var showPopover = false

Button("Info") {
    showPopover = true
}
.popover(isPresented: $showPopover) {
    PopoverContent()
        .frame(width: 300, height: 200)
}

// Attachment anchor
.popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom)) {
    PopoverContent()
}

// Arrow edge
.popover(isPresented: $showPopover, arrowEdge: .top) {
    PopoverContent()
}
```

## Alerts

```swift
@State private var showAlert = false

.alert("Delete Item?", isPresented: $showAlert) {
    Button("Delete", role: .destructive) {
        deleteItem()
    }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("This action cannot be undone.")
}

// With data
@State private var itemToDelete: Item?

.alert("Delete \(itemToDelete?.name ?? "")?", isPresented: $showDeleteAlert, presenting: itemToDelete) { item in
    Button("Delete", role: .destructive) {
        delete(item)
    }
    Button("Cancel", role: .cancel) { }
}
```

## Confirmation Dialog

```swift
@State private var showConfirmation = false

.confirmationDialog("Select Action", isPresented: $showConfirmation) {
    Button("Share") { }
    Button("Duplicate") { }
    Button("Delete", role: .destructive) { }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("Choose what to do with this item")
}
```

## Inspector (iOS 17+)

```swift
@State private var showInspector = false

NavigationStack {
    ContentView()
        .inspector(isPresented: $showInspector) {
            InspectorContent()
                .inspectorColumnWidth(min: 200, ideal: 300, max: 400)
        }
        .toolbar {
            Button("Inspector", systemImage: "sidebar.right") {
                showInspector.toggle()
            }
        }
}
```

## iOS Version Notes

- iOS 16+: Sheet detents, presentation modifiers
- iOS 17+: Inspector, improved animations
- iOS 18+: New transition options

## Gotchas

1. **Sheet in NavigationStack** - Sheet gets own navigation context
2. **Popover on iPhone** - Falls back to sheet automatically
3. **Multiple presentations** - Can't present from already presented view
4. **State on dismiss** - Reset state in onDismiss handler
5. **Keyboard in sheets** - May need scroll view for forms

## Related

- [navigation.md](navigation.md) - When to use push vs sheet
- [menus.md](menus.md) - Action sheets via confirmationDialog
