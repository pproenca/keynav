# Nearby Interaction

## Overview

Nearby Interaction uses Ultra-Wideband (UWB) for precise distance and direction to other devices.

## When to Use

- Proximity-based features
- Device handoff
- Spatial awareness
- AirTag-like interactions

## Basic Setup

```swift
import NearbyInteraction

class ProximityManager: NSObject, NISessionDelegate {
    var session: NISession?

    func start() {
        session = NISession()
        session?.delegate = self

        // Get discovery token to share
        let myToken = session?.discoveryToken
        // Exchange token with peer device
    }

    func connect(with peerToken: NIDiscoveryToken) {
        let config = NINearbyPeerConfiguration(peerToken: peerToken)
        session?.run(config)
    }

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        for object in nearbyObjects {
            if let distance = object.distance {
                print("Distance: \(distance)m")
            }
            if let direction = object.direction {
                // 3D vector pointing to object
                print("Direction: \(direction)")
            }
        }
    }

    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        // Peer moved out of range
    }
}
```

## Requirements

- iPhone 11+ (U1 chip)
- Both devices need NI support
- Exchange discovery tokens

## Related

- [homekit.md](homekit.md) - Proximity for home automation
