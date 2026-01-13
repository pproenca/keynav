---
name: ios-ai-ar
description: |
  iOS AI and augmented reality frameworks. Covers ARKit for building AR experiences
  with plane detection and object anchoring, RealityKit for 3D rendering, Core ML
  for running machine learning models on device, Vision framework for image analysis,
  generative AI integration patterns with Apple Intelligence, and MapKit for maps
  and location features. Use this skill when: (1) Building AR experiences, (2)
  Running ML models on device, (3) Image classification or detection, (4) Integrating
  generative AI, (5) Adding maps and directions, (6) User asks about "ARKit", "AR",
  "augmented reality", "RealityKit", "Core ML", "machine learning", "Vision",
  "image recognition", "generative AI", "Apple Intelligence", "MapKit", "maps".
---

# iOS AI & AR

Augmented reality, machine learning, and intelligent features.

## Quick Decision Tree

```
3D/spatial content?
├── AR camera → ARKit + RealityKit
├── 3D without camera → RealityKit/SceneKit
└── No 3D → Other frameworks

ML task?
├── Image → Vision framework
├── Text → Natural Language
├── Custom model → Core ML
└── Generative AI → Apple Intelligence APIs

Location?
├── Maps display → MapKit
├── Just coordinates → Core Location
└── Directions → MapKit directions API
```

## Quick Start - ARKit

```swift
import ARKit
import RealityKit

struct ARContentView: View {
    var body: some View {
        ARViewContainer()
            .ignoresSafeArea()
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configure session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)

        // Add 3D content
        let anchor = AnchorEntity(plane: .horizontal)
        let box = ModelEntity(mesh: .generateBox(size: 0.1))
        box.model?.materials = [SimpleMaterial(color: .blue, isMetallic: true)]
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) { }
}
```

## Quick Start - Core ML

```swift
import CoreML
import Vision

func classifyImage(_ image: UIImage) async throws -> String {
    // Load model
    let model = try VNCoreMLModel(for: MobileNetV2().model)

    // Create request
    let request = VNCoreMLRequest(model: model)

    // Perform request
    guard let cgImage = image.cgImage else { throw MLError.invalidImage }

    let handler = VNImageRequestHandler(cgImage: cgImage)
    try handler.perform([request])

    // Get results
    guard let results = request.results as? [VNClassificationObservation],
          let topResult = results.first
    else { throw MLError.noResults }

    return "\(topResult.identifier): \(topResult.confidence * 100)%"
}
```

## Quick Start - MapKit

```swift
import MapKit

struct MapContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.009),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: locations) { location in
            MapMarker(coordinate: location.coordinate, tint: .red)
        }
    }
}

// iOS 17+ new Map API
Map {
    Marker("Apple Park", coordinate: appleParkCoordinate)
    UserAnnotation()
}
.mapStyle(.standard(elevation: .realistic))
```

## Reference Files

- **ARKit**: See [references/arkit.md](references/arkit.md) - Sessions, anchors, RealityKit
- **Core ML**: See [references/coreml.md](references/coreml.md) - Models, Vision, on-device inference
- **Generative AI**: See [references/generative-ai.md](references/generative-ai.md) - Apple Intelligence patterns
- **Maps**: See [references/maps.md](references/maps.md) - MapKit, annotations, directions

## Common Gotchas

1. **AR requires A12+ chip** - Check device capability
2. **Core ML model size** - Large models impact app size
3. **Camera permissions** - Required for AR and Vision
4. **Map annotations limit** - Too many markers hurt performance
5. **Apple Intelligence** - Only on supported devices/regions
