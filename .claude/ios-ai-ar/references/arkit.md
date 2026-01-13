# ARKit

## Overview

ARKit provides augmented reality with plane detection, image tracking, object anchoring, and face tracking.

## When to Use

- AR experiences
- Product visualization
- Interactive 3D content
- Face filters

## Basic AR View

```swift
import ARKit
import RealityKit

struct ARExperienceView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configure world tracking
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic

        arView.session.run(config)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) { }
}
```

## Place 3D Content

```swift
// On horizontal plane
let anchor = AnchorEntity(plane: .horizontal)
let box = ModelEntity(mesh: .generateBox(size: 0.1))
box.model?.materials = [SimpleMaterial(color: .blue, isMetallic: true)]
anchor.addChild(box)
arView.scene.addAnchor(anchor)

// At tap location
func handleTap(at point: CGPoint) {
    guard let result = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal).first else { return }

    let anchor = AnchorEntity(world: result.worldTransform)
    anchor.addChild(myModel)
    arView.scene.addAnchor(anchor)
}
```

## Image Tracking

```swift
let config = ARWorldTrackingConfiguration()

guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
config.detectionImages = referenceImages

arView.session.run(config)

// Handle detection
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors {
        if let imageAnchor = anchor as? ARImageAnchor {
            // Place content on detected image
            let imageName = imageAnchor.referenceImage.name
        }
    }
}
```

## Face Tracking

```swift
guard ARFaceTrackingConfiguration.isSupported else { return }

let config = ARFaceTrackingConfiguration()
arView.session.run(config)

// Access face geometry and blend shapes
func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    for anchor in anchors {
        if let faceAnchor = anchor as? ARFaceAnchor {
            let smile = faceAnchor.blendShapes[.mouthSmileLeft]
        }
    }
}
```

## Related

- [coreml.md](coreml.md) - ML in AR experiences
- [maps.md](maps.md) - Location-based AR
