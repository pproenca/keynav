# Undo and Redo

## Overview

iOS provides UndoManager for implementing undo/redo functionality. SwiftUI integrates with system undo via environment.

## When to Use

- Document editing apps
- Drawing and design tools
- Any app where users modify data
- Form editing with undo support

## Environment UndoManager

```swift
@Environment(\.undoManager) var undoManager

func updateName(_ newName: String) {
    let oldName = item.name

    undoManager?.registerUndo(withTarget: item) { item in
        item.name = oldName
    }
    undoManager?.setActionName("Rename")

    item.name = newName
}
```

## SwiftUI Observable Integration

```swift
@Observable
class Document {
    var text: String = ""
    var undoManager: UndoManager?

    func updateText(_ newText: String) {
        let oldText = text

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateText(oldText)
        }
        undoManager?.setActionName("Edit Text")

        text = newText
    }
}

struct EditorView: View {
    @Bindable var document: Document
    @Environment(\.undoManager) var undoManager

    var body: some View {
        TextEditor(text: $document.text)
            .onAppear {
                document.undoManager = undoManager
            }
    }
}
```

## Grouping Undo Operations

```swift
undoManager?.beginUndoGrouping()

// Multiple operations
item.name = newName
item.color = newColor
item.size = newSize

undoManager?.endUndoGrouping()
undoManager?.setActionName("Update Item")
```

## Undo Menu Commands

```swift
// SwiftUI provides automatic Edit menu with undo/redo
// For custom menu items:

.commands {
    CommandGroup(after: .undoRedo) {
        Button("Undo All") {
            while undoManager?.canUndo == true {
                undoManager?.undo()
            }
        }
        .keyboardShortcut("z", modifiers: [.command, .shift])
    }
}
```

## Shake to Undo

```swift
// Enabled by default on iOS
// Disable per-view:
.onShakeGesture(enabled: false)

// Or in Info.plist:
// UIApplicationSupportsShakeToEdit = NO
```

## Toolbar Undo/Redo Buttons

```swift
.toolbar {
    ToolbarItemGroup(placement: .primaryAction) {
        Button {
            undoManager?.undo()
        } label: {
            Image(systemName: "arrow.uturn.backward")
        }
        .disabled(!(undoManager?.canUndo ?? false))

        Button {
            undoManager?.redo()
        } label: {
            Image(systemName: "arrow.uturn.forward")
        }
        .disabled(!(undoManager?.canRedo ?? false))
    }
}
```

## UIKit Integration

```swift
// In UIKit view controller
override var undoManager: UndoManager? {
    return document.undoManager
}

override var canBecomeFirstResponder: Bool {
    return true
}

// Register for undo
document.undoManager?.registerUndo(withTarget: self) { target in
    target.revertChange()
}
```

## Undo Levels

```swift
// Set maximum undo levels
undoManager?.levelsOfUndo = 20

// Clear undo stack
undoManager?.removeAllActions()

// Clear for specific target
undoManager?.removeAllActions(withTarget: item)
```

## Undo Notifications

```swift
NotificationCenter.default.addObserver(
    forName: .NSUndoManagerDidUndoChange,
    object: undoManager,
    queue: .main
) { _ in
    // Handle undo performed
}

NotificationCenter.default.addObserver(
    forName: .NSUndoManagerDidRedoChange,
    object: undoManager,
    queue: .main
) { _ in
    // Handle redo performed
}
```

## iOS Version Notes

- iOS 16+: Baseline UndoManager support
- iOS 17+: Improved Observable integration
- iOS 18+: Enhanced document support

## Gotchas

1. **Retain cycles** - Use `[weak self]` in undo closures
2. **State synchronization** - Update UI when undo occurs
3. **Undo during editing** - Handle active text field
4. **Undo stack persistence** - Clear on document save/close if needed
5. **Grouped operations** - Always balance begin/end grouping

## Related

- [menus.md](menus.md) - Edit menu with undo commands
- [navigation.md](navigation.md) - Undo in navigation context
