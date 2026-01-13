# App Clips

## Overview

App Clips are lightweight versions of apps (<10MB) that provide quick functionality without full installation.

## When to Use

- Quick transactions (parking, ordering, payments)
- Location-based experiences
- QR/NFC triggered actions
- Preview of full app functionality

## App Clip Target

```swift
// Create new target: File → New → Target → App Clip

// Shared code between main app and App Clip
// Use shared framework or target membership

// App Clip specific code
#if APPCLIP
// App Clip only code
#endif
```

## App Clip Card

```swift
// Configure in App Store Connect
// Provide:
// - Header image (1800x1200)
// - Title
// - Subtitle
// - Action button text

// Invocation URLs registered in App Store Connect
// e.g., https://appclip.example.com/store/123
```

## Handle Invocation

```swift
import AppClip

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL
        else { return }

        // Parse URL to determine what to show
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let storeID = components?.queryItems?.first(where: { $0.name == "store" })?.value {
            navigateToStore(id: storeID)
        }
    }
}

// SwiftUI
@main
struct MyAppClip: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    handleActivity(activity)
                }
        }
    }
}
```

## Location Verification

```swift
import AppClip

// Verify user is at expected location
let activity = userActivity

guard let payload = activity.appClipActivationPayload else { return }

payload.confirmAcquired(in: CLCircularRegion(
    center: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.009),
    radius: 100,
    identifier: "store"
)) { inRegion, error in
    if inRegion {
        // User is at location, show relevant content
        showStoreContent()
    } else {
        // User not at location
        showGenericContent()
    }
}
```

## Ephemeral Notification

```swift
// Request ephemeral notifications (8 hours validity)
import UserNotifications

let center = UNUserNotificationCenter.current()
center.requestAuthorization(options: [.alert, .sound, .provisional]) { granted, error in
    // Provisional auth for App Clips
}
```

## Promote Full App

```swift
import StoreKit

// Show App Store overlay
SKOverlay.AppClipConfiguration(position: .bottom)

// Present overlay
let overlay = SKOverlay(configuration: config)
overlay.present(in: windowScene)

// Check if full app installed
if let fullAppURL = URL(string: "myapp://") {
    if UIApplication.shared.canOpenURL(fullAppURL) {
        // Full app is installed
    }
}
```

## Data Migration

```swift
// Share data with full app via App Group
let defaults = UserDefaults(suiteName: "group.com.example.app")
defaults?.set(userData, forKey: "migrationData")

// Full app reads on first launch
if let data = defaults?.object(forKey: "migrationData") {
    importData(data)
    defaults?.removeObject(forKey: "migrationData")
}
```

## Size Optimization

```swift
// Keep under 10MB uncompressed
// Tips:
// - Minimize assets
// - Use SF Symbols
// - Lazy load images
// - Remove unused code
// - Use App Thinning

// Check size
// Product → Archive → Distribute App → App Clip Size Report
```

## Invocation Methods

```swift
/*
1. QR Code - Generate with invocation URL
2. NFC Tag - Encode invocation URL
3. App Clip Code - Apple's visual code (recommended)
4. Safari - Smart Banner with meta tag
5. Messages - Links in conversations
6. Maps - Place card integration
7. Siri Suggestions - Based on location
*/

// Safari Smart Banner
// <meta name="apple-itunes-app" content="app-clip-bundle-id=com.example.appclip, app-id=123456789">
```

## iOS Version Notes

- iOS 16+: Baseline App Clips
- iOS 17+: Enhanced location verification
- iOS 18+: Improved discovery

## Gotchas

1. **10MB limit** - Uncompressed size, strictly enforced
2. **Limited APIs** - Some frameworks unavailable
3. **No background** - App Clips can't run in background
4. **8-hour window** - Notifications only valid for 8 hours
5. **Keychain** - Different keychain than full app

## Related

- [siri.md](siri.md) - Siri can suggest App Clips
- [sign-in-apple.md](sign-in-apple.md) - Auth in App Clips
