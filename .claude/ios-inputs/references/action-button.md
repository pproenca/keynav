# Action Button

## Overview

The Action button on iPhone 15 Pro and later replaces the mute switch. Apps can register actions to run when the button is pressed.

## When to Use

- Providing quick access to app features
- Custom camera actions
- Quick note or voice memo capture
- Any frequently used action

## App Intent for Action Button

```swift
import AppIntents

struct QuickCaptureIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Capture"
    static var description = IntentDescription("Capture a photo quickly")

    // Show in Shortcuts and Action Button settings
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // Perform the action
        await capturePhoto()
        return .result()
    }
}
```

## Register Action Button Intent

```swift
// In your App file or scene delegate
import AppIntents

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        // Register intents for Action Button
        AppDependencyManager.shared.add(dependency: QuickCaptureIntent.self)
    }
}
```

## Info.plist Configuration

```xml
<key>NSUserActivityTypes</key>
<array>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER).QuickCaptureIntent</string>
</array>
```

## Handle Intent Launch

```swift
struct ContentView: View {
    @State private var showCapture = false

    var body: some View {
        MainView()
            .onContinueUserActivity("com.app.QuickCaptureIntent") { _ in
                showCapture = true
            }
            .sheet(isPresented: $showCapture) {
                CaptureView()
            }
    }
}
```

## Action Button with Parameters

```swift
struct RecordVoiceIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Voice"
    static var description = IntentDescription("Start voice recording")

    @Parameter(title: "Duration")
    var duration: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("Record for \(\.$duration) seconds")
    }

    func perform() async throws -> some IntentResult {
        let recordDuration = duration ?? 30
        await startRecording(duration: recordDuration)
        return .result()
    }
}
```

## Camera Control (iPhone 16+)

```swift
// Camera Control button is separate from Action button
// Use AVCaptureEventInteraction for camera control

import AVFoundation

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!

    override func viewDidLoad() {
        super.viewDidLoad()

        let interaction = AVCaptureEventInteraction { [weak self] event in
            switch event.phase {
            case .began:
                // Light press - prepare
                self?.prepareCapture()
            case .ended:
                // Full press - capture
                self?.capturePhoto()
            case .cancelled:
                self?.cancelCapture()
            @unknown default:
                break
            }
        }
        view.addInteraction(interaction)
    }
}
```

## Background Execution

```swift
struct BackgroundActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Background Action"

    // Don't open app
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        // Quick background action
        await quickAction()
        return .result()
    }
}
```

## Shortcuts Integration

```swift
// Make intent available in Shortcuts app
struct MyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickCaptureIntent(),
            phrases: [
                "Quick capture with \(.applicationName)",
                "Take a quick photo"
            ],
            shortTitle: "Quick Capture",
            systemImageName: "camera"
        )
    }
}
```

## iOS Version Notes

- iOS 17+: Action button on iPhone 15 Pro/Pro Max
- iOS 18+: Camera Control on iPhone 16, enhanced Action button

## Gotchas

1. **User must configure** - User chooses which app/action in Settings
2. **Competition** - System actions (Flashlight, Camera) take priority
3. **Background limits** - Background intents have time limits
4. **Testing** - Requires physical device with Action button
5. **Discovery** - Help users find Action button setting

## Related

- [sensors.md](sensors.md) - Motion-triggered actions
- [gestures.md](gestures.md) - On-screen quick actions
