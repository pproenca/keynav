---
name: ios-media-social
description: |
  iOS media and social features. Covers SharePlay for shared FaceTime experiences,
  Game Center for achievements and leaderboards, Live Photos capture and playback,
  Photo editing extensions, ShazamKit for audio recognition, iMessage apps and
  sticker packs, and AirPlay for wireless streaming. Use this skill when: (1)
  Building SharePlay experiences, (2) Adding Game Center features, (3) Working
  with Live Photos, (4) Creating photo editors, (5) Implementing audio recognition,
  (6) Building iMessage apps, (7) Adding AirPlay support, (8) User asks about
  "SharePlay", "FaceTime", "Game Center", "achievements", "leaderboard", "Live
  Photo", "ShazamKit", "Shazam", "iMessage", "stickers", "AirPlay".
---

# iOS Media & Social

Media playback, social features, and content sharing for iOS apps.

## Quick Decision Tree

```
Social/shared experience?
├── Real-time with FaceTime → SharePlay
├── Gaming achievements → Game Center
└── Messaging → iMessage app

Media feature?
├── Audio recognition → ShazamKit
├── Photo with motion → Live Photos
├── Photo editing → PHContentEditingController
└── Wireless display → AirPlay
```

## Quick Start - SharePlay

```swift
import GroupActivities

struct WatchTogetherActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Watch Together"
        metadata.type = .watchTogether
        return metadata
    }
}

// Start activity
func startSharePlay() async throws {
    let activity = WatchTogetherActivity()
    let result = try await activity.activate()

    switch result {
    case .activationPreferred:
        // Activity started
        break
    case .activationDisabled:
        // User disabled
        break
    case .cancelled:
        // User cancelled
        break
    @unknown default:
        break
    }
}
```

## Quick Start - Game Center

```swift
import GameKit

// Authenticate
GKLocalPlayer.local.authenticateHandler = { viewController, error in
    if let vc = viewController {
        present(vc)
    } else if GKLocalPlayer.local.isAuthenticated {
        loadAchievements()
    }
}

// Submit score
GKLeaderboard.submitScore(1000, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["high_scores"]) { error in
    // Score submitted
}

// Report achievement
let achievement = GKAchievement(identifier: "first_win")
achievement.percentComplete = 100
GKAchievement.report([achievement]) { error in }
```

## Quick Start - ShazamKit

```swift
import ShazamKit

let session = SHSession()
session.delegate = self

// Match audio
let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: 4096)!

session.matchStreamingBuffer(buffer, at: nil)

// Delegate callback
func session(_ session: SHSession, didFind match: SHMatch) {
    if let item = match.mediaItems.first {
        print("Found: \(item.title ?? "Unknown")")
    }
}
```

## Reference Files

- **SharePlay**: See [references/shareplay.md](references/shareplay.md) - Group activities, state sync
- **Game Center**: See [references/game-center.md](references/game-center.md) - Auth, leaderboards, achievements
- **Live Photos**: See [references/live-photos.md](references/live-photos.md) - Capture, playback
- **Photo Editing**: See [references/photo-editing.md](references/photo-editing.md) - Extensions, filters
- **ShazamKit**: See [references/shazamkit.md](references/shazamkit.md) - Audio matching
- **iMessage**: See [references/imessage.md](references/imessage.md) - Apps, stickers
- **AirPlay**: See [references/airplay.md](references/airplay.md) - Wireless streaming

## Common Gotchas

1. **SharePlay requires FaceTime** - User must be in call
2. **Game Center sign-in** - Handle when user declines
3. **ShazamKit limits** - Free tier has recognition limits
4. **iMessage app size** - Keep bundle small for fast loading
5. **AirPlay testing** - Requires Apple TV or compatible device
