# Mac Catalyst

## Overview

Mac Catalyst brings iOS apps to Mac with minimal changes. Optimize UIKit for Mac interaction patterns.

## When to Use

- Bringing iOS app to Mac
- Shared codebase for iOS and Mac
- When SwiftUI multiplatform isn't sufficient

## Enable Catalyst

```swift
// In Xcode: General → Deployment Info → Mac (Mac Catalyst)
// Or in project settings: SUPPORTS_MACCATALYST = YES
```

## Platform Detection

```swift
#if targetEnvironment(macCatalyst)
// Mac Catalyst specific code
#else
// iOS specific code
#endif

// Runtime check
if UIDevice.current.userInterfaceIdiom == .mac {
    // Running on Mac
}

// ProcessInfo
if ProcessInfo.processInfo.isMacCatalystApp {
    // Mac Catalyst
}
```

## Mac Menu Bar

```swift
override func buildMenu(with builder: UIMenuBuilder) {
    super.buildMenu(with: builder)

    // Add custom menu
    let customMenu = UIMenu(
        title: "Custom",
        children: [
            UIAction(title: "Action", image: UIImage(systemName: "star")) { _ in
                performAction()
            }
        ]
    )
    builder.insertSibling(customMenu, afterMenu: .file)

    // Remove unwanted menus
    builder.remove(menu: .format)
}
```

## Mac Toolbar

```swift
#if targetEnvironment(macCatalyst)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession...) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly

        windowScene.titlebar?.toolbar = toolbar
        windowScene.titlebar?.toolbarStyle = .unified
    }
}

extension SceneDelegate: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier...) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.image = UIImage(systemName: "plus")
        item.action = #selector(addItem)
        return item
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.add, .flexibleSpace, .search]
    }
}
#endif
```

## Window Management

```swift
// Minimum/maximum window size
UIApplication.shared.connectedScenes
    .compactMap { $0 as? UIWindowScene }
    .first?
    .sizeRestrictions?.minimumSize = CGSize(width: 800, height: 600)

// Full screen support
windowScene.sizeRestrictions?.allowsFullScreen = true
```

## Pointer Interactions

```swift
// Hover effect
view.addInteraction(UIPointerInteraction(delegate: self))

extension ViewController: UIPointerInteractionDelegate {
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return UIPointerStyle(effect: .highlight(UITargetedPreview(view: interaction.view!)))
    }
}

// SwiftUI hover
Button("Action") { }
    .hoverEffect(.lift)
```

## Keyboard Shortcuts

```swift
// UIKit
override var keyCommands: [UIKeyCommand]? {
    return [
        UIKeyCommand(
            title: "New",
            action: #selector(newDocument),
            input: "n",
            modifierFlags: .command
        )
    ]
}

// SwiftUI
Button("New") { }
    .keyboardShortcut("n", modifiers: .command)
```

## Touch Bar (older Macs)

```swift
#if targetEnvironment(macCatalyst)
override func makeTouchBar() -> NSTouchBar? {
    let touchBar = NSTouchBar()
    touchBar.delegate = self
    touchBar.defaultItemIdentifiers = [.action1, .action2]
    return touchBar
}
#endif
```

## Optimize for Mac

```swift
// Scale interface
#if targetEnvironment(macCatalyst)
// In Info.plist: UIApplicationSceneManifest → Scene Configuration →
// Application Session Role → Configuration → UIApplicationScaleInterface = false

// Or dynamically
windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1024, height: 768)
#endif

// Hide home indicator area equivalent
.ignoresSafeArea(.container, edges: .bottom)
```

## iOS Version Notes

- iOS 16+/macOS 12+: Baseline Catalyst
- iOS 17+/macOS 14+: Enhanced window management
- iOS 18+/macOS 15+: Improved performance

## Gotchas

1. **Not all APIs available** - Some iOS APIs don't work on Mac
2. **UI sizing** - Interface may look too large; consider scaling
3. **Touch vs click** - Test pointer interactions thoroughly
4. **App Store** - Catalyst apps on Mac App Store, not iOS store
5. **Entitlements** - Some require separate Mac entitlements

## Related

- [carplay.md](carplay.md) - Another platform expansion
- [siri.md](siri.md) - Siri works on Mac too
