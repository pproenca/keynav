# Game Center

## Overview

Game Center provides achievements, leaderboards, challenges, and multiplayer for games.

## When to Use

- Adding achievements
- Leaderboards
- Multiplayer matchmaking
- Player profiles

## Authentication

```swift
import GameKit

func authenticatePlayer() {
    GKLocalPlayer.local.authenticateHandler = { viewController, error in
        if let vc = viewController {
            // Present Game Center login
            self.present(vc, animated: true)
        } else if GKLocalPlayer.local.isAuthenticated {
            // Player signed in
            self.loadAchievements()
            self.loadLeaderboards()
        } else if let error = error {
            print("Auth error: \(error)")
        }
    }
}
```

## Leaderboards

```swift
// Submit score
func submitScore(_ score: Int, to leaderboardID: String) {
    GKLeaderboard.submitScore(
        score,
        context: 0,
        player: GKLocalPlayer.local,
        leaderboardIDs: [leaderboardID]
    ) { error in
        if let error = error {
            print("Score submit error: \(error)")
        }
    }
}

// Show leaderboard
func showLeaderboard() {
    let vc = GKGameCenterViewController(state: .leaderboards)
    vc.gameCenterDelegate = self
    present(vc, animated: true)
}
```

## Achievements

```swift
// Report achievement progress
func reportAchievement(_ identifier: String, percentComplete: Double) {
    let achievement = GKAchievement(identifier: identifier)
    achievement.percentComplete = percentComplete
    achievement.showsCompletionBanner = true

    GKAchievement.report([achievement]) { error in
        if let error = error {
            print("Achievement error: \(error)")
        }
    }
}

// Show achievements
func showAchievements() {
    let vc = GKGameCenterViewController(state: .achievements)
    vc.gameCenterDelegate = self
    present(vc, animated: true)
}
```

## Multiplayer

```swift
// Real-time matchmaking
let request = GKMatchRequest()
request.minPlayers = 2
request.maxPlayers = 4

let vc = GKMatchmakerViewController(matchRequest: request)
vc?.matchmakerDelegate = self
present(vc!, animated: true)

// Handle match
func matchmakerViewController(_ vc: GKMatchmakerViewController, didFind match: GKMatch) {
    vc.dismiss(animated: true)
    match.delegate = self
    startGame(with: match)
}
```

## Related

- [shareplay.md](shareplay.md) - FaceTime multiplayer
