# CarPlay

## Overview

CarPlay extends iOS apps to vehicle displays. Supports audio, navigation, communication, EV charging, parking, and quick food ordering.

## When to Use

- Audio playback apps (music, podcasts, audiobooks)
- Navigation apps
- Communication apps (messaging, VoIP)
- EV charging station apps
- Parking apps
- Quick food ordering apps

## CarPlay Entitlement

```xml
<!-- Required entitlement from Apple -->
<key>com.apple.developer.carplay-audio</key>
<true/>

<!-- Or for navigation -->
<key>com.apple.developer.carplay-maps</key>
<true/>
```

## Audio App Setup

```swift
import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController

        let tabBar = CPTabBarTemplate(templates: [
            createNowPlayingTemplate(),
            createBrowseTemplate(),
            createSearchTemplate()
        ])
        interfaceController.setRootTemplate(tabBar, animated: true)
    }

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
    }
}
```

## List Template

```swift
func createBrowseTemplate() -> CPListTemplate {
    let items = albums.map { album in
        let item = CPListItem(text: album.title, detailText: album.artist)
        item.handler = { [weak self] _, completion in
            self?.playAlbum(album)
            completion()
        }
        return item
    }

    let section = CPListSection(items: items)
    let template = CPListTemplate(title: "Library", sections: [section])
    template.tabImage = UIImage(systemName: "music.note.list")

    return template
}
```

## Now Playing Template

```swift
func createNowPlayingTemplate() -> CPNowPlayingTemplate {
    let template = CPNowPlayingTemplate.shared

    template.updateNowPlayingButtons([
        CPNowPlayingShuffleButton(handler: { _ in
            self.toggleShuffle()
        }),
        CPNowPlayingRepeatButton(handler: { _ in
            self.toggleRepeat()
        })
    ])

    template.tabImage = UIImage(systemName: "play.circle")
    return template
}
```

## Navigation App

```swift
class NavigationSceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var mapTemplate: CPMapTemplate!

    func templateApplicationScene(_ scene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        mapTemplate = CPMapTemplate()
        mapTemplate.mapDelegate = self

        // Configure map buttons
        let zoomIn = CPMapButton { _ in
            self.zoomIn()
        }
        zoomIn.image = UIImage(systemName: "plus")

        mapTemplate.mapButtons = [zoomIn]

        interfaceController.setRootTemplate(mapTemplate, animated: false)
    }
}

extension NavigationSceneDelegate: CPMapTemplateDelegate {
    func mapTemplate(_ mapTemplate: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        // Handle pan gesture
    }

    func mapTemplate(_ mapTemplate: CPMapTemplate, startedTrip trip: CPTrip, using routeChoice: CPRouteChoice) {
        // Start navigation
    }
}
```

## Trip and Navigation

```swift
// Create trip
let origin = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation))
let destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoord))

let trip = CPTrip(
    origin: origin,
    destination: destination,
    routeChoices: [
        CPRouteChoice(summaryVariants: ["Fastest Route"], additionalInformationVariants: ["via Highway"], selectionSummaryVariants: ["25 min"])
    ]
)

// Present trip preview
mapTemplate.showTripPreviews([trip], textConfiguration: nil)

// Start navigation
mapTemplate.startNavigationSession(for: trip)
```

## Voice Control

```swift
// Handle Siri for CarPlay
func application(_ application: UIApplication, handle intent: INIntent, completion: @escaping (INIntentResponse) -> Void) {
    if let playIntent = intent as? INPlayMediaIntent {
        // Handle play request
    }
}
```

## Scene Configuration

```swift
// Info.plist
/*
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UISceneConfigurations</key>
    <dict>
        <key>CPTemplateApplicationSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneClassName</key>
                <string>CPTemplateApplicationScene</string>
                <key>UISceneConfigurationName</key>
                <string>CarPlay</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).CarPlaySceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
*/
```

## iOS Version Notes

- iOS 16+: Baseline CarPlay templates
- iOS 17+: Enhanced EV charging, parking templates
- iOS 18+: New quick service templates

## Gotchas

1. **Entitlement required** - Must request from Apple developer portal
2. **Template limits** - Maximum 5 tabs, limited nesting
3. **Simulator** - Use CarPlay Simulator in Xcode
4. **Driver safety** - Minimize interaction; voice-first design
5. **Background audio** - Audio app must support background playback

## Related

- [siri.md](siri.md) - Voice control in CarPlay
- [mac-catalyst.md](mac-catalyst.md) - Another platform expansion
