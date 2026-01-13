# Photo Editing

## Overview

Photo editing extensions allow apps to provide editing capabilities within the Photos app.

## When to Use

- Building photo editor apps
- Creating Photos app extensions
- Applying filters and adjustments
- Non-destructive editing

## Photo Editing Extension

```swift
import PhotosUI

class PhotoEditingViewController: UIViewController, PHContentEditingController {
    var input: PHContentEditingInput?

    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return adjustmentData.formatIdentifier == "com.app.filter"
    }

    func startContentEditing(with input: PHContentEditingInput, placeholderImage: UIImage) {
        self.input = input

        // Display image for editing
        if let fullImage = input.displaySizeImage {
            imageView.image = fullImage
        }
    }

    func finishContentEditing(completionHandler: @escaping (PHContentEditingOutput?) -> Void) {
        guard let input = input else {
            completionHandler(nil)
            return
        }

        // Create output
        let output = PHContentEditingOutput(contentEditingInput: input)

        // Save adjustment data
        let adjustmentData = PHAdjustmentData(
            formatIdentifier: "com.app.filter",
            formatVersion: "1.0",
            data: filterSettings.encode()
        )
        output.adjustmentData = adjustmentData

        // Render edited image
        let editedImage = applyFilters(to: input.displaySizeImage!)
        let jpegData = editedImage.jpegData(compressionQuality: 0.9)!
        try? jpegData.write(to: output.renderedContentURL)

        completionHandler(output)
    }

    func cancelContentEditing() {
        // Clean up
    }

    var shouldShowCancelConfirmation: Bool {
        return hasChanges
    }
}
```

## Core Image Filters

```swift
import CoreImage

func applyFilter(to image: UIImage, filterName: String) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }

    let filter = CIFilter(name: filterName)
    filter?.setValue(ciImage, forKey: kCIInputImageKey)

    // Filter-specific parameters
    if filterName == "CISepiaTone" {
        filter?.setValue(0.8, forKey: kCIInputIntensityKey)
    }

    guard let outputImage = filter?.outputImage else { return nil }

    let context = CIContext()
    guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

    return UIImage(cgImage: cgImage)
}

// Common filters
// CIPhotoEffectMono - Black and white
// CIPhotoEffectChrome - Chrome effect
// CISepiaTone - Sepia
// CIVignette - Vignette
// CIGaussianBlur - Blur
// CIColorControls - Brightness, contrast, saturation
```

## PHPickerViewController

```swift
import PhotosUI

func presentPhotoPicker() {
    var config = PHPickerConfiguration()
    config.selectionLimit = 1
    config.filter = .images

    let picker = PHPickerViewController(configuration: config)
    picker.delegate = self
    present(picker, animated: true)
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.editImage(image)
                }
            }
        }
    }
}
```

## PhotosPicker (SwiftUI)

```swift
import PhotosUI

struct ImagePicker: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Label("Select Photo", systemImage: "photo")
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
}
```

## Related

- [live-photos.md](live-photos.md) - Live Photo editing
- [shazamkit.md](shazamkit.md) - Audio in photos
