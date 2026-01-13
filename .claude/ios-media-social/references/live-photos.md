# Live Photos

## Overview

Live Photos capture 1.5 seconds of motion and audio before and after a photo is taken.

## When to Use

- Photo capture with motion
- Animated photo display
- Live Photo editing
- Key frame extraction

## Display Live Photo

```swift
import PhotosUI

struct LivePhotoView: UIViewRepresentable {
    let livePhoto: PHLivePhoto

    func makeUIView(context: Context) -> PHLivePhotoView {
        let view = PHLivePhotoView()
        view.livePhoto = livePhoto
        view.contentMode = .scaleAspectFit
        return view
    }

    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.livePhoto = livePhoto
    }
}

// Auto-play on long press (default behavior)
// Or programmatically:
livePhotoView.startPlayback(with: .full)
```

## Load from Photos Library

```swift
import Photos

func loadLivePhoto(asset: PHAsset) async throws -> PHLivePhoto {
    let options = PHLivePhotoRequestOptions()
    options.deliveryMode = .highQualityFormat

    return try await withCheckedThrowingContinuation { continuation in
        PHImageManager.default().requestLivePhoto(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { livePhoto, info in
            if let livePhoto = livePhoto {
                continuation.resume(returning: livePhoto)
            } else {
                continuation.resume(throwing: PhotoError.loadFailed)
            }
        }
    }
}
```

## Capture Live Photo

```swift
import AVFoundation

// Configure capture session
let photoOutput = AVCapturePhotoOutput()
photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported

// Capture
let settings = AVCapturePhotoSettings()
settings.livePhotoMovieFileURL = livePhotoURL
photoOutput.capturePhoto(with: settings, delegate: self)

// Handle result
func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    // Photo captured
}

func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
    // Live Photo movie captured
}
```

## Extract Still Image

```swift
// Get key frame from Live Photo
func extractStillImage(from livePhoto: PHLivePhoto) -> UIImage? {
    // Live Photos store the still as the first frame
    // Use PHAssetResource to access
    return nil  // Requires PHAssetResource extraction
}
```

## Related

- [photo-editing.md](photo-editing.md) - Edit Live Photos
- [shareplay.md](shareplay.md) - Share Live Photos
