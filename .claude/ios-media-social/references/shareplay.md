# SharePlay

## Overview

SharePlay enables shared experiences during FaceTime calls with synchronized playback and state.

## When to Use

- Watch together experiences
- Listen together
- Collaborative activities
- Shared games

## Group Activity

```swift
import GroupActivities

struct MovieWatchingActivity: GroupActivity {
    let movie: Movie

    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = movie.title
        meta.subtitle = "Watch together"
        meta.type = .watchTogether
        meta.previewImage = movie.posterImage
        return meta
    }
}

// Start activity
func startSharePlay(movie: Movie) async {
    let activity = MovieWatchingActivity(movie: movie)

    switch await activity.prepareForActivation() {
    case .activationPreferred:
        try? await activity.activate()
    case .activationDisabled:
        // SharePlay disabled
        break
    case .cancelled:
        break
    @unknown default:
        break
    }
}
```

## State Synchronization

```swift
class SharePlayViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0

    private var groupSession: GroupSession<MovieWatchingActivity>?
    private var messenger: GroupSessionMessenger?

    func configureSession(_ session: GroupSession<MovieWatchingActivity>) {
        groupSession = session

        // Observe state changes
        session.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                }
            }
            .store(in: &subscriptions)

        // Set up messenger
        messenger = GroupSessionMessenger(session: session)

        // Join session
        session.join()
    }

    func sync(isPlaying: Bool, time: TimeInterval) async throws {
        let state = PlaybackState(isPlaying: isPlaying, time: time)
        try await messenger?.send(state)
    }
}
```

## Receive State

```swift
func observeMessages() {
    Task {
        for await (message, _) in messenger.messages(of: PlaybackState.self) {
            await MainActor.run {
                self.isPlaying = message.isPlaying
                self.currentTime = message.time
            }
        }
    }
}
```

## Related

- [airplay.md](airplay.md) - Wireless streaming
- [game-center.md](game-center.md) - Multiplayer games
