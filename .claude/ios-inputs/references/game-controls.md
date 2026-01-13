# Game Controls

## Overview

GameController framework provides unified access to MFi controllers, PlayStation, Xbox, and other Bluetooth game controllers.

## When to Use

- Building games with controller support
- Implementing controller-based UI navigation
- Supporting haptic feedback on controllers
- Handling multiple connected controllers

## Basic Controller Setup

```swift
import GameController

class GameInputManager: ObservableObject {
    @Published var controllers: [GCController] = []

    init() {
        setupNotifications()
        discoverControllers()
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil, queue: .main
        ) { [weak self] notification in
            if let controller = notification.object as? GCController {
                self?.controllerConnected(controller)
            }
        }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil, queue: .main
        ) { [weak self] notification in
            if let controller = notification.object as? GCController {
                self?.controllerDisconnected(controller)
            }
        }
    }

    func discoverControllers() {
        GCController.startWirelessControllerDiscovery()
        controllers = GCController.controllers()
    }

    func controllerConnected(_ controller: GCController) {
        controllers = GCController.controllers()
        configureController(controller)
    }

    func controllerDisconnected(_ controller: GCController) {
        controllers = GCController.controllers()
    }
}
```

## Extended Gamepad Input

```swift
func configureController(_ controller: GCController) {
    guard let gamepad = controller.extendedGamepad else { return }

    // D-Pad
    gamepad.dpad.valueChangedHandler = { dpad, xValue, yValue in
        // xValue: -1 (left) to 1 (right)
        // yValue: -1 (down) to 1 (up)
    }

    // Thumbsticks
    gamepad.leftThumbstick.valueChangedHandler = { stick, xValue, yValue in
        self.movePlayer(x: xValue, y: yValue)
    }

    gamepad.rightThumbstick.valueChangedHandler = { stick, xValue, yValue in
        self.rotateCamera(x: xValue, y: yValue)
    }

    // Face buttons (A/B/X/Y)
    gamepad.buttonA.pressedChangedHandler = { button, value, pressed in
        if pressed { self.jump() }
    }

    gamepad.buttonB.pressedChangedHandler = { button, value, pressed in
        if pressed { self.dodge() }
    }

    // Triggers
    gamepad.leftTrigger.valueChangedHandler = { trigger, value, pressed in
        self.aim(intensity: value)
    }

    gamepad.rightTrigger.valueChangedHandler = { trigger, value, pressed in
        if pressed { self.fire() }
    }

    // Shoulder buttons
    gamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
        if pressed { self.previousWeapon() }
    }
}
```

## Controller Haptics

```swift
// Check haptics support
guard let haptics = controller.haptics else { return }

// Play haptic pattern
let engine = haptics.createEngine(withLocality: .default)
try? engine?.start()

// Simple vibration
let player = try? engine?.makePlayer(with: CHHapticPattern(events: [
    CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ],
        relativeTime: 0
    )
], parameters: []))
try? player?.start(atTime: CHHapticTimeImmediate)
```

## Controller Light

```swift
// Change controller light color (DualShock, DualSense)
controller.light?.color = GCColor(red: 1, green: 0, blue: 0)
```

## Micro Gamepad (Siri Remote)

```swift
if let microGamepad = controller.microGamepad {
    microGamepad.dpad.valueChangedHandler = { dpad, xValue, yValue in
        // Navigate UI
    }

    microGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
        // Select
    }

    microGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
        // Play/Pause
    }
}
```

## Virtual Controller

```swift
// Create on-screen virtual controller
let virtualController = GCVirtualController(configuration: GCVirtualController.Configuration())

// Customize elements
virtualController.configuration.elements = [
    GCInputLeftThumbstick,
    GCInputRightThumbstick,
    GCInputButtonA,
    GCInputButtonB
]

// Show/hide
virtualController.connect()
virtualController.disconnect()
```

## Polling vs Handlers

```swift
// Handler-based (recommended - automatic)
gamepad.buttonA.pressedChangedHandler = { button, value, pressed in
    // Called when state changes
}

// Polling-based (for game loop)
func gameLoop() {
    guard let gamepad = GCController.current?.extendedGamepad else { return }

    let leftX = gamepad.leftThumbstick.xAxis.value
    let leftY = gamepad.leftThumbstick.yAxis.value
    let aPressed = gamepad.buttonA.isPressed

    updateGame(stick: (leftX, leftY), jump: aPressed)
}
```

## Menu Navigation

```swift
// System menu button
gamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
    if pressed { self.showPauseMenu() }
}

// Options button
gamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
    if pressed { self.showOptionsMenu() }
}
```

## iOS Version Notes

- iOS 16+: Baseline GameController framework
- iOS 17+: Enhanced haptics, new button mappings
- iOS 18+: Spatial gaming support

## Gotchas

1. **Multiple controllers** - Track player assignment
2. **Controller disconnect** - Handle gracefully mid-game
3. **Button mapping** - Xbox/PlayStation labels differ
4. **Simulator** - Connect real controller via Bluetooth
5. **tvOS focus** - Controllers integrate with focus system

## Related

- [sensors.md](sensors.md) - Motion controls
- [focus-selection.md](focus-selection.md) - Controller navigation patterns
