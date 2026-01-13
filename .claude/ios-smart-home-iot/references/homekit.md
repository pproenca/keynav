# HomeKit

## Overview

HomeKit provides secure control of smart home accessories with Siri integration.

## When to Use

- Smart home apps
- Device control
- Home automation
- Siri home commands

## Setup

```swift
import HomeKit

class HomeManager: NSObject, HMHomeManagerDelegate {
    let manager = HMHomeManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        for home in manager.homes {
            print("Home: \(home.name)")
            for room in home.rooms {
                print("  Room: \(room.name)")
                for accessory in room.accessories {
                    print("    Accessory: \(accessory.name)")
                }
            }
        }
    }
}
```

## Control Accessories

```swift
func toggleLight(_ accessory: HMAccessory) {
    // Find lightbulb service
    guard let lightService = accessory.services.first(where: {
        $0.serviceType == HMServiceTypeLightbulb
    }) else { return }

    // Find power characteristic
    guard let powerChar = lightService.characteristics.first(where: {
        $0.characteristicType == HMCharacteristicTypePowerState
    }) else { return }

    // Toggle
    let currentValue = powerChar.value as? Bool ?? false
    powerChar.writeValue(!currentValue) { error in
        if let error = error {
            print("Error: \(error)")
        }
    }
}

// Set brightness
func setBrightness(_ accessory: HMAccessory, value: Int) {
    // Find brightness characteristic
    guard let service = accessory.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }),
          let brightnessChar = service.characteristics.first(where: {
              $0.characteristicType == HMCharacteristicTypeBrightness
          })
    else { return }

    brightnessChar.writeValue(value) { error in }
}
```

## Automation

```swift
// Create automation
func createAutomation(home: HMHome) {
    // Trigger at sunset
    let trigger = HMEventTrigger(
        name: "Sunset Lights",
        events: [HMSignificantTimeEvent(significantEvent: .sunset, offset: nil)],
        predicate: nil
    )

    home.addTrigger(trigger) { error in
        // Add action set
    }
}
```

## Info.plist

```xml
<key>NSHomeKitUsageDescription</key>
<string>Control your smart home devices</string>
```

## Related

- [nfc.md](nfc.md) - NFC for home automation triggers
