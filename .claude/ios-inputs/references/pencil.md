# Apple Pencil

## Overview

Apple Pencil support includes PencilKit for drawing, Scribble for handwriting recognition, and custom touch handling for stylus input.

## When to Use

- Building drawing/sketching apps
- Supporting handwriting input
- Creating annotation features
- Handling pressure/tilt-sensitive input

## PencilKit Drawing

```swift
import PencilKit

struct DrawingView: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.tool = PKInkingTool(.pen, color: .black, width: 5)

        // Allow finger drawing on iPhone
        canvas.drawingPolicy = .anyInput

        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.drawing = drawing
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}
```

## Tool Picker

```swift
struct DrawingViewWithPicker: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing

        // Show tool picker
        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()

        return canvas
    }
}
```

## Drawing Tools

```swift
// Pen
canvas.tool = PKInkingTool(.pen, color: .blue, width: 3)

// Pencil (textured)
canvas.tool = PKInkingTool(.pencil, color: .gray, width: 5)

// Marker (translucent)
canvas.tool = PKInkingTool(.marker, color: .yellow, width: 20)

// Eraser
canvas.tool = PKEraserTool(.bitmap)  // Pixel eraser
canvas.tool = PKEraserTool(.vector)  // Stroke eraser

// Lasso (selection)
canvas.tool = PKLassoTool()
```

## Export Drawing

```swift
// As UIImage
let image = drawing.image(from: drawing.bounds, scale: UIScreen.main.scale)

// As Data
let data = drawing.dataRepresentation()

// Save to file
try? data.write(to: fileURL)

// Load from file
if let data = try? Data(contentsOf: fileURL) {
    drawing = try PKDrawing(data: data)
}
```

## Scribble (Handwriting to Text)

```swift
// Scribble is automatic for text fields on iPadOS
// User writes with Apple Pencil, system converts to text

TextField("Name", text: $name)
    // Scribble enabled by default

// Disable Scribble for specific field
TextField("Drawing area", text: $text)
    .allowsHitTesting(false)  // Prevents Scribble
```

## Pencil Hover (iPad Pro M2+)

```swift
struct HoverView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = HoverableView()
        return view
    }
}

class HoverableView: UIView {
    override func hoverEnded(_ interaction: UIHoverGestureRecognizer) {
        // Pencil moved away
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.type == .pencil {
                // Pencil hover position
                let location = touch.preciseLocation(in: self)
                let altitude = touch.altitudeAngle
                let azimuth = touch.azimuthAngle(in: self)
            }
        }
    }
}
```

## Pressure and Tilt

```swift
// In custom drawing implementation
func draw(touch: UITouch, in view: UIView) {
    let location = touch.location(in: view)

    // Pressure (0.0 to 1.0+, can exceed 1.0)
    let pressure = touch.force / touch.maximumPossibleForce

    // Altitude (angle from surface, 0 = flat, π/2 = perpendicular)
    let altitude = touch.altitudeAngle

    // Azimuth (rotation around perpendicular axis)
    let azimuth = touch.azimuthAngle(in: view)

    // Adjust stroke based on pressure/tilt
    let width = baseWidth * pressure
}
```

## Double Tap Action

```swift
// Handle Apple Pencil double-tap
class CanvasViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = self
        view.addInteraction(pencilInteraction)
    }
}

extension CanvasViewController: UIPencilInteractionDelegate {
    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        // User double-tapped pencil
        // Default behavior configured in Settings
        switch UIPencilInteraction.preferredTapAction {
        case .switchEraser:
            toggleEraser()
        case .showColorPalette:
            showColors()
        default:
            break
        }
    }
}
```

## iOS Version Notes

- iOS 16+: Baseline PencilKit
- iPadOS 17+: Pencil hover support
- iOS 18+: Enhanced palm rejection

## Gotchas

1. **Finger vs Pencil** - Check `touch.type == .pencil` to differentiate
2. **Drawing policy** - Set `.pencilOnly` if finger should scroll
3. **Palm rejection** - PencilKit handles automatically
4. **Tool picker visibility** - Must make canvas first responder
5. **Simulator testing** - No Pencil support; test on device

## Related

- [gestures.md](gestures.md) - Touch gesture handling
- [sensors.md](sensors.md) - Device motion input
