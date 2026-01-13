---
name: ios-platform-integration
description: |
  iOS platform integration and system services. Covers Siri with App Intents and
  Shortcuts, Sign in with Apple for authentication, iCloud sync with CloudKit and
  NSUbiquitousKeyValueStore, Mac Catalyst for Mac ports, CarPlay for vehicle
  integration, App Clips for lightweight instant experiences, Always On display
  support, and VoiceOver accessibility integration. Use this skill when: (1) Adding
  Siri/voice support, (2) Implementing Sign in with Apple, (3) Using iCloud sync,
  (4) Porting to Mac with Catalyst, (5) Building CarPlay apps, (6) Creating App
  Clips, (7) User asks about "Siri", "App Intents", "Shortcuts", "Sign in with
  Apple", "iCloud", "CloudKit", "Mac Catalyst", "CarPlay", "App Clips", "Always On",
  "VoiceOver".
---

# iOS Platform Integration

Deep platform integration and system services for iOS apps.

## Quick Decision Tree

```
Need voice/Siri support?
├── Yes → App Intents + Shortcuts
└── No
    Need authentication?
    ├── Yes → Sign in with Apple
    └── No
        Need cross-device sync?
        ├── Yes → iCloud (CloudKit or KV Store)
        └── No
            Platform expansion?
            ├── Mac → Mac Catalyst
            ├── Vehicle → CarPlay
            └── Quick experience → App Clip
```

## Quick Start - App Intents

```swift
import AppIntents

struct OpenProjectIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Project"
    static var description = IntentDescription("Opens a project in the app")

    @Parameter(title: "Project Name")
    var projectName: String

    func perform() async throws -> some IntentResult {
        await openProject(named: projectName)
        return .result()
    }
}
```

## Quick Start - Sign in with Apple

```swift
import AuthenticationServices

SignInWithAppleButton(.signIn) { request in
    request.requestedScopes = [.fullName, .email]
} onCompletion: { result in
    switch result {
    case .success(let auth):
        handleAuthorization(auth)
    case .failure(let error):
        handleError(error)
    }
}
```

## Quick Start - iCloud Key-Value

```swift
// Simple sync with NSUbiquitousKeyValueStore
let store = NSUbiquitousKeyValueStore.default

// Write
store.set("value", forKey: "myKey")
store.synchronize()

// Read
let value = store.string(forKey: "myKey")

// Listen for changes
NotificationCenter.default.addObserver(
    forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
    object: store, queue: .main
) { _ in
    // Refresh from iCloud
}
```

## Reference Files

- **Siri**: See [references/siri.md](references/siri.md) - App Intents, Shortcuts, SiriKit
- **Sign in with Apple**: See [references/sign-in-apple.md](references/sign-in-apple.md) - Auth flow, tokens
- **iCloud**: See [references/icloud.md](references/icloud.md) - CloudKit, KV Store, sync
- **Mac Catalyst**: See [references/mac-catalyst.md](references/mac-catalyst.md) - Mac optimization
- **CarPlay**: See [references/carplay.md](references/carplay.md) - Templates, audio, navigation
- **App Clips**: See [references/app-clips.md](references/app-clips.md) - Creation, invocation
- **Always On**: See [references/always-on.md](references/always-on.md) - Display states
- **VoiceOver**: See [references/voiceover.md](references/voiceover.md) - Accessibility integration

## Common Gotchas

1. **App Intents vs SiriKit** - Use App Intents (newer, recommended) unless specific domain needed
2. **Sign in with Apple required** - Mandatory if app has third-party sign-in options
3. **iCloud limits** - NSUbiquitousKeyValueStore: 1MB total, 1024 keys max
4. **Catalyst UI** - Many UIKit features need adaptation for Mac
5. **App Clip size** - Must be under 10MB uncompressed
