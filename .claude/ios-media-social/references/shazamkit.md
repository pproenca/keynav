# ShazamKit

## Overview

ShazamKit enables audio recognition against Shazam's catalog or custom audio catalogs.

## When to Use

- Music recognition
- Audio watermarking
- Custom audio matching
- Content synchronization

## Basic Music Recognition

```swift
import ShazamKit

class MusicRecognizer: NSObject, SHSessionDelegate {
    let session = SHSession()
    let audioEngine = AVAudioEngine()

    override init() {
        super.init()
        session.delegate = self
    }

    func startListening() throws {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { buffer, time in
            self.session.matchStreamingBuffer(buffer, at: time)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopListening() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }

    // Delegate methods
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let item = match.mediaItems.first else { return }

        print("Title: \(item.title ?? "Unknown")")
        print("Artist: \(item.artist ?? "Unknown")")
        print("Album: \(item.albumTitle ?? "Unknown")")

        if let artworkURL = item.artworkURL {
            // Load artwork
        }

        if let appleMusicURL = item.appleMusicURL {
            // Open in Apple Music
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("No match found")
    }
}
```

## Match from Audio File

```swift
func matchAudioFile(at url: URL) async throws -> SHMatch? {
    let audioFile = try AVAudioFile(forReading: url)
    let signature = try SHSignatureGenerator.signature(from: audioFile)

    return try await withCheckedThrowingContinuation { continuation in
        session.match(signature)
        // Handle in delegate
    }
}
```

## Custom Catalog

```swift
// Create custom catalog for your own audio
let catalog = SHCustomCatalog()

// Add reference signatures
let referenceSignature = try SHSignatureGenerator.signature(from: referenceAudioFile)
let mediaItem = SHMediaItem(properties: [
    .title: "My Song",
    .artist: "My Artist"
])

try catalog.addReferenceSignature(referenceSignature, representing: [mediaItem])

// Save catalog
try catalog.write(to: catalogURL)

// Use custom catalog
let session = SHSession(catalog: catalog)
```

## Library Integration

```swift
// Add recognized song to Shazam library
func addToShazamLibrary(_ item: SHMediaItem) {
    SHMediaLibrary.default.add([item]) { error in
        if let error = error {
            print("Failed to add: \(error)")
        }
    }
}
```

## Microphone Permission

```swift
// Info.plist
// NSMicrophoneUsageDescription - "Identify songs playing around you"

// Request permission
AVAudioSession.sharedInstance().requestRecordPermission { granted in
    if granted {
        try? self.startListening()
    }
}
```

## Related

- [shareplay.md](shareplay.md) - Shared music experiences
- [game-center.md](game-center.md) - Audio in games
