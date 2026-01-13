# Sensors

## Overview

CoreMotion provides access to device motion sensors: accelerometer, gyroscope, magnetometer, and barometer.

## When to Use

- Motion-based interactions (shake, tilt)
- Fitness and activity tracking
- Augmented reality positioning
- Pedometer and altitude data

## CoreMotion Setup

```swift
import CoreMotion

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()

    @Published var acceleration: CMAcceleration = CMAcceleration()
    @Published var rotationRate: CMRotationRate = CMRotationRate()

    func startUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }

        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            self?.acceleration = data.acceleration
        }
    }

    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}
```

## Accelerometer

```swift
// Raw accelerometer data (includes gravity)
motionManager.startAccelerometerUpdates(to: .main) { data, error in
    guard let data = data else { return }
    let x = data.acceleration.x  // -1 to 1 (g-force)
    let y = data.acceleration.y
    let z = data.acceleration.z
}

// Check device orientation
let isUpsideDown = data.acceleration.z < -0.8
let isFaceDown = data.acceleration.y < -0.8
```

## Gyroscope

```swift
guard motionManager.isGyroAvailable else { return }

motionManager.gyroUpdateInterval = 1.0 / 60.0
motionManager.startGyroUpdates(to: .main) { data, error in
    guard let data = data else { return }
    let rotationX = data.rotationRate.x  // radians/second
    let rotationY = data.rotationRate.y
    let rotationZ = data.rotationRate.z
}
```

## Device Motion (Sensor Fusion)

```swift
// Combined, processed motion data (recommended)
guard motionManager.isDeviceMotionAvailable else { return }

motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
motionManager.startDeviceMotionUpdates(
    using: .xArbitraryZVertical,
    to: .main
) { motion, error in
    guard let motion = motion else { return }

    // Attitude (orientation)
    let pitch = motion.attitude.pitch
    let roll = motion.attitude.roll
    let yaw = motion.attitude.yaw

    // User acceleration (gravity removed)
    let userAccel = motion.userAcceleration

    // Gravity vector
    let gravity = motion.gravity

    // Rotation rate
    let rotation = motion.rotationRate
}
```

## Shake Detection

```swift
// UIKit approach
class ShakeViewController: UIViewController {
    override var canBecomeFirstResponder: Bool { true }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            handleShake()
        }
    }
}

// Manual detection with accelerometer
func detectShake(acceleration: CMAcceleration) {
    let magnitude = sqrt(
        pow(acceleration.x, 2) +
        pow(acceleration.y, 2) +
        pow(acceleration.z, 2)
    )
    if magnitude > 2.5 {  // Threshold
        onShake()
    }
}
```

## Pedometer

```swift
let pedometer = CMPedometer()

// Check availability
guard CMPedometer.isStepCountingAvailable() else { return }

// Get today's steps
pedometer.queryPedometerData(from: startOfDay, to: Date()) { data, error in
    guard let data = data else { return }
    let steps = data.numberOfSteps.intValue
    let distance = data.distance?.doubleValue  // meters
}

// Live updates
pedometer.startUpdates(from: Date()) { data, error in
    guard let data = data else { return }
    // Update UI with step count
}
```

## Altimeter

```swift
let altimeter = CMAltimeter()

// Check availability
guard CMAltimeter.isRelativeAltitudeAvailable() else { return }

// Start updates
altimeter.startRelativeAltitudeUpdates(to: .main) { data, error in
    guard let data = data else { return }
    let relativeAltitude = data.relativeAltitude.doubleValue  // meters
    let pressure = data.pressure.doubleValue  // kPa
}
```

## Motion Activity

```swift
let activityManager = CMMotionActivityManager()

// Check availability
guard CMMotionActivityManager.isActivityAvailable() else { return }

// Get current activity
activityManager.startActivityUpdates(to: .main) { activity in
    guard let activity = activity else { return }

    if activity.walking {
        print("Walking")
    } else if activity.running {
        print("Running")
    } else if activity.cycling {
        print("Cycling")
    } else if activity.automotive {
        print("In vehicle")
    } else if activity.stationary {
        print("Stationary")
    }

    let confidence = activity.confidence  // .low, .medium, .high
}
```

## Privacy Permissions

```swift
// Info.plist required keys:
// NSMotionUsageDescription - for motion data

// Check authorization
switch CMMotionActivityManager.authorizationStatus() {
case .authorized:
    startTracking()
case .notDetermined:
    // Will prompt on first use
    requestPermission()
case .denied, .restricted:
    showPermissionDeniedAlert()
@unknown default:
    break
}
```

## iOS Version Notes

- iOS 16+: Baseline CoreMotion
- iOS 17+: Enhanced activity recognition
- watchOS: Extended sensor access

## Gotchas

1. **Simulator** - No sensor data; test on device
2. **Battery impact** - Stop updates when not needed
3. **Background** - Requires background mode for continued access
4. **Update interval** - Don't request faster than needed
5. **Coordinate system** - Reference frame matters for attitude

## Related

- [game-controls.md](game-controls.md) - Motion controls for games
- [action-button.md](action-button.md) - Motion-triggered quick actions
