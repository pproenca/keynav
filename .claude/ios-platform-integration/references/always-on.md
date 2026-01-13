# Always On

## Overview

Always On display keeps content visible when the device is locked or screen appears off. Supported on iPhone 14 Pro+ and Apple Watch.

## When to Use

- Time-sensitive information
- Glanceable content
- Status displays
- Clock/timer apps

## Check Support

```swift
// Check if Always On is available
import UIKit

if #available(iOS 16.0, *) {
    // Always On available on supported devices
    // No direct API to check - design for both states
}
```

## Reduced Luminance State

```swift
// Trait collection indicates reduced luminance
class ViewController: UIViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceLevel == .elevated {
            // Normal display
            updateForNormalDisplay()
        } else {
            // Could be Always On state - reduce visual complexity
            updateForReducedDisplay()
        }
    }
}
```

## SwiftUI Environment

```swift
struct ContentView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced

    var body: some View {
        VStack {
            if isLuminanceReduced {
                // Simplified UI for Always On
                SimplifiedTimeView()
            } else {
                // Full UI
                DetailedView()
            }
        }
    }
}
```

## Design Guidelines

```swift
// Always On design principles:

// 1. Reduce refresh rate
// - Minimize animations
// - Use static content where possible

// 2. Darken UI
// - Use darker colors
// - Reduce brightness of images

// 3. Hide sensitive content
// - Blur or hide notifications
// - Hide personal data

// 4. Simplify layout
// - Show essential information only
// - Large, readable text

struct AlwaysOnAwareView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            if isLuminanceReduced {
                // Minimal content
                Text(timeString)
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(.white.opacity(0.8))
            } else {
                // Full content
                FullDashboardView()
            }
        }
    }
}
```

## Widgets and Lock Screen

```swift
// Widgets automatically adapt to Always On
// Use redacted modifier for sensitive content

struct MyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MyWidget", provider: Provider()) { entry in
            MyWidgetView(entry: entry)
                .privacySensitive()  // Hides in Always On
        }
    }
}

// Or custom redaction
struct SensitiveView: View {
    @Environment(\.redactionReasons) var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            Text("••••")
        } else {
            Text(accountBalance)
        }
    }
}
```

## Live Activities

```swift
// Live Activities work with Always On
import ActivityKit

struct DeliveryActivityContent: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var status: String
        var eta: Date
    }
}

// Configure for Always On
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryActivityContent.self) { context in
            // Lock screen presentation
            DeliveryView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Dynamic Island content
            } compactLeading: {
                Image(systemName: "box.truck")
            } compactTrailing: {
                Text(context.state.eta, style: .timer)
            } minimal: {
                Image(systemName: "box.truck")
            }
        }
    }
}
```

## Performance Considerations

```swift
// Reduce updates in Always On state
class DataManager: ObservableObject {
    @Published var data: Data

    private var updateTimer: Timer?

    func startUpdates(isReduced: Bool) {
        updateTimer?.invalidate()

        let interval: TimeInterval = isReduced ? 60 : 1  // Slower in Always On
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.refreshData()
        }
    }
}
```

## iOS Version Notes

- iOS 16+: Always On on iPhone 14 Pro/Pro Max
- iOS 17+: Enhanced customization
- watchOS: Always On since Series 5

## Gotchas

1. **No direct detection** - Can't directly check if Always On is active
2. **Battery impact** - Minimize updates to save battery
3. **Privacy** - Hide sensitive content automatically
4. **Testing** - Lock device to test Always On behavior
5. **Animations** - System pauses animations in reduced state

## Related

- [voiceover.md](voiceover.md) - Accessibility in Always On
- [app-clips.md](app-clips.md) - Quick glanceable content
