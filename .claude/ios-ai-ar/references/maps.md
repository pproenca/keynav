# Maps

## Overview

MapKit provides interactive maps, annotations, directions, and location search.

## When to Use

- Displaying maps
- Location-based features
- Directions and routing
- Place search

## SwiftUI Map

```swift
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.009),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: locations) { location in
            MapMarker(coordinate: location.coordinate, tint: .red)
        }
    }
}

// iOS 17+ new API
Map {
    Marker("Apple Park", coordinate: applePark)
    Annotation("Custom", coordinate: location) {
        Circle().fill(.blue).frame(width: 20)
    }
    UserAnnotation()
}
.mapStyle(.standard(elevation: .realistic))
```

## Directions

```swift
func getDirections(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> [MKRoute] {
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
    request.transportType = .automobile

    let directions = MKDirections(request: request)
    let response = try await directions.calculate()

    return response.routes
}

// Display route
Map {
    MapPolyline(route.polyline)
        .stroke(.blue, lineWidth: 5)
}
```

## Search

```swift
func searchPlaces(query: String, near coordinate: CLLocationCoordinate2D) async throws -> [MKMapItem] {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.region = MKCoordinateRegion(
        center: coordinate,
        latitudinalMeters: 10000,
        longitudinalMeters: 10000
    )

    let search = MKLocalSearch(request: request)
    let response = try await search.start()

    return response.mapItems
}
```

## Look Around

```swift
// Look Around preview (street view)
@State private var lookAroundScene: MKLookAroundScene?

Map {
    // ...
}
.safeAreaInset(edge: .bottom) {
    if let scene = lookAroundScene {
        LookAroundPreview(scene: scene)
            .frame(height: 200)
    }
}
.onTapGesture { location in
    Task {
        lookAroundScene = try? await MKLookAroundSceneRequest(coordinate: coord).scene
    }
}
```

## Related

- [arkit.md](arkit.md) - Location-based AR
- [coreml.md](coreml.md) - ML for location features
