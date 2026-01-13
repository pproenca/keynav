# AirPlay

## Overview

AirPlay streams audio and video to Apple TV, HomePod, and compatible speakers/displays.

## When to Use

- Video streaming to TV
- Audio to speakers
- Screen mirroring
- Multi-room audio

## AirPlay Button

```swift
import AVKit

// Standard AirPlay button
struct ContentView: View {
    var body: some View {
        AVRoutePickerView()
            .frame(width: 44, height: 44)
    }
}

// UIKit
class PlayerViewController: UIViewController {
    func setupAirPlay() {
        let routePicker = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        routePicker.activeTintColor = .systemBlue
        routePicker.delegate = self
        view.addSubview(routePicker)
    }
}
```

## External Display Detection

```swift
import UIKit

class ExternalDisplayManager {
    var externalWindow: UIWindow?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidConnect),
            name: UIScreen.didConnectNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidDisconnect),
            name: UIScreen.didDisconnectNotification,
            object: nil
        )

        // Check for already connected screens
        if UIScreen.screens.count > 1 {
            setupExternalScreen(UIScreen.screens[1])
        }
    }

    @objc func screenDidConnect(_ notification: Notification) {
        guard let screen = notification.object as? UIScreen else { return }
        setupExternalScreen(screen)
    }

    @objc func screenDidDisconnect(_ notification: Notification) {
        externalWindow?.isHidden = true
        externalWindow = nil
    }

    func setupExternalScreen(_ screen: UIScreen) {
        externalWindow = UIWindow(frame: screen.bounds)
        externalWindow?.screen = screen
        externalWindow?.rootViewController = ExternalDisplayViewController()
        externalWindow?.isHidden = false
    }
}
```

## AVPlayer with AirPlay

```swift
import AVFoundation

let player = AVPlayer(url: videoURL)

// Enable AirPlay
player.allowsExternalPlayback = true

// Check if playing externally
if player.isExternalPlaybackActive {
    // Show "Playing on Apple TV" UI
}

// Observe external playback
player.addObserver(self, forKeyPath: "externalPlaybackActive", options: [.new], context: nil)

override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "externalPlaybackActive" {
        updateUIForExternalPlayback()
    }
}
```

## Audio Routing

```swift
import AVFAudio

// Get current route
let session = AVAudioSession.sharedInstance()
let currentRoute = session.currentRoute

for output in currentRoute.outputs {
    print("Port: \(output.portName)")
    print("Type: \(output.portType)")
}

// Listen for route changes
NotificationCenter.default.addObserver(
    forName: AVAudioSession.routeChangeNotification,
    object: nil, queue: .main
) { notification in
    guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
          let routeChangeReason = AVAudioSession.RouteChangeReason(rawValue: reason)
    else { return }

    switch routeChangeReason {
    case .newDeviceAvailable:
        // New output available
        break
    case .oldDeviceUnavailable:
        // Output removed
        break
    default:
        break
    }
}
```

## Picture in Picture with AirPlay

```swift
import AVKit

let playerVC = AVPlayerViewController()
playerVC.player = player
playerVC.allowsPictureInPicturePlayback = true

// PiP continues when AirPlaying
```

## Require AirPlay

```swift
// Force AirPlay for specific content
player.allowsExternalPlayback = true
player.usesExternalPlaybackWhileExternalScreenIsActive = true
```

## Related

- [shareplay.md](shareplay.md) - Shared watching
- [live-photos.md](live-photos.md) - Display Live Photos on TV
