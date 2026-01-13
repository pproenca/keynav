---
name: ios-smart-home-iot
description: |
  iOS smart home and IoT frameworks. Covers HomeKit for controlling smart home
  accessories (lights, thermostats, locks), NFC for reading/writing tags, and
  nearby interactions for device proximity detection. Use this skill when: (1)
  Building smart home apps, (2) Controlling HomeKit accessories, (3) Implementing
  NFC tag scanning, (4) Using proximity detection, (5) User asks about "HomeKit",
  "smart home", "home automation", "Siri home", "NFC", "tag", "NDEF", "nearby
  interaction", "UWB", "proximity".
---

# iOS Smart Home & IoT

Smart home control and IoT device integration.

## Quick Decision Tree

```
Device type?
├── HomeKit accessory → HomeKit framework
├── NFC tag → Core NFC
├── Proximity/direction → Nearby Interaction
└── Bluetooth device → Core Bluetooth
```

## Quick Start - HomeKit

```swift
import HomeKit

class HomeManager: NSObject, HMHomeManagerDelegate {
    let homeManager = HMHomeManager()

    override init() {
        super.init()
        homeManager.delegate = self
    }

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        // Homes loaded
        for home in manager.homes {
            print("Home: \(home.name)")
            for room in home.rooms {
                for accessory in room.accessories {
                    print("  \(accessory.name)")
                }
            }
        }
    }

    // Control accessory
    func toggleLight(_ accessory: HMAccessory) {
        guard let service = accessory.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }),
              let characteristic = service.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState })
        else { return }

        let newValue = !(characteristic.value as? Bool ?? false)
        characteristic.writeValue(newValue) { error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
}
```

## Quick Start - NFC

```swift
import CoreNFC

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    func startReading() {
        guard NFCNDEFReaderSession.readingAvailable else { return }

        let session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session.alertMessage = "Hold your iPhone near the tag"
        session.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let payload = String(data: record.payload, encoding: .utf8) {
                    print("Read: \(payload)")
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Handle error
    }
}
```

## Quick Start - Nearby Interaction

```swift
import NearbyInteraction

class ProximityManager: NSObject, NISessionDelegate {
    var session: NISession?

    func startSession(with token: NIDiscoveryToken) {
        session = NISession()
        session?.delegate = self

        let config = NINearbyPeerConfiguration(peerToken: token)
        session?.run(config)
    }

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        for object in nearbyObjects {
            if let distance = object.distance {
                print("Distance: \(distance) meters")
            }
            if let direction = object.direction {
                print("Direction: \(direction)")
            }
        }
    }
}
```

## Reference Files

- **HomeKit**: See [references/homekit.md](references/homekit.md) - Homes, accessories, automation
- **NFC**: See [references/nfc.md](references/nfc.md) - Reading, writing, background tags
- **Nearby Interaction**: See [references/nearby-interaction.md](references/nearby-interaction.md) - UWB proximity

## Common Gotchas

1. **HomeKit entitlement** - Required capability and Info.plist key
2. **NFC requires iPhone 7+** - Not available on older devices or iPad
3. **Nearby Interaction needs UWB** - iPhone 11+ with U1 chip
4. **HomeKit testing** - Use HomeKit Accessory Simulator
5. **Background NFC** - Only works with specific tag formats
