# Core ML

## Overview

Core ML runs machine learning models on device for image classification, object detection, and more.

## When to Use

- Image classification
- Object detection
- Natural language processing
- Custom predictions

## Using Vision with Core ML

```swift
import CoreML
import Vision

func classifyImage(_ image: UIImage) async throws -> [VNClassificationObservation] {
    guard let cgImage = image.cgImage else { throw MLError.invalidImage }

    // Load model
    let model = try VNCoreMLModel(for: MobileNetV2().model)

    // Create request
    let request = VNCoreMLRequest(model: model)
    request.imageCropAndScaleOption = .centerCrop

    // Process
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    return request.results as? [VNClassificationObservation] ?? []
}
```

## Object Detection

```swift
func detectObjects(in image: UIImage) async throws -> [VNRecognizedObjectObservation] {
    guard let cgImage = image.cgImage else { throw MLError.invalidImage }

    let model = try VNCoreMLModel(for: YOLOv3().model)
    let request = VNCoreMLRequest(model: model)

    let handler = VNImageRequestHandler(cgImage: cgImage)
    try handler.perform([request])

    return request.results as? [VNRecognizedObjectObservation] ?? []
}

// Access bounding boxes
for observation in results {
    let boundingBox = observation.boundingBox  // Normalized coordinates
    let label = observation.labels.first?.identifier
    let confidence = observation.labels.first?.confidence
}
```

## Custom Model

```swift
// Convert model with coremltools (Python)
// import coremltools
// model = coremltools.convert(pytorch_model)
// model.save("MyModel.mlpackage")

// Use in Swift
let model = try MyModel(configuration: MLModelConfiguration())
let prediction = try model.prediction(input: inputFeatures)
```

## On-Device Training

```swift
// Update model with new data
let updateTask = try MLUpdateTask(
    forModelAt: modelURL,
    trainingData: trainingData,
    configuration: nil,
    completionHandler: { context in
        // Save updated model
        try? context.model.write(to: updatedModelURL)
    }
)
updateTask.resume()
```

## Related

- [arkit.md](arkit.md) - ML in AR experiences
- [generative-ai.md](generative-ai.md) - Apple Intelligence
