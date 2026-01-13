# HealthKit

## Overview

HealthKit provides a central repository for health and fitness data, enabling apps to read and write health metrics.

## When to Use

- Fitness tracking apps
- Health monitoring
- Workout logging
- Sleep tracking
- Nutrition logging

## Setup

```swift
// 1. Enable HealthKit capability in Xcode
// 2. Add Info.plist keys:
//    NSHealthShareUsageDescription - Why you read data
//    NSHealthUpdateUsageDescription - Why you write data

import HealthKit

class HealthManager {
    let healthStore = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
}
```

## Request Authorization

```swift
func requestAuthorization() async throws {
    let readTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.heartRate),
        HKQuantityType(.activeEnergyBurned),
        HKCategoryType(.sleepAnalysis),
        HKObjectType.workoutType()
    ]

    let writeTypes: Set<HKSampleType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned)
    ]

    try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
}
```

## Query Data Types

### Statistics Query (Aggregated)

```swift
func getTodaySteps() async throws -> Double {
    let stepType = HKQuantityType(.stepCount)
    let startOfDay = Calendar.current.startOfDay(for: Date())

    let predicate = HKQuery.predicateForSamples(
        withStart: startOfDay,
        end: Date(),
        options: .strictStartDate
    )

    return try await withCheckedThrowingContinuation { continuation in
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            continuation.resume(returning: steps)
        }
        healthStore.execute(query)
    }
}
```

### Sample Query (Individual Samples)

```swift
func getHeartRateSamples() async throws -> [HKQuantitySample] {
    let heartRateType = HKQuantityType(.heartRate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

    return try await withCheckedThrowingContinuation { continuation in
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: 100,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
        }
        healthStore.execute(query)
    }
}
```

## Write Data

```swift
func saveSteps(count: Double, date: Date) async throws {
    let stepType = HKQuantityType(.stepCount)
    let quantity = HKQuantity(unit: .count(), doubleValue: count)

    let sample = HKQuantitySample(
        type: stepType,
        quantity: quantity,
        start: date,
        end: date
    )

    try await healthStore.save(sample)
}
```

## Workouts

```swift
func saveWorkout(
    type: HKWorkoutActivityType,
    start: Date,
    end: Date,
    calories: Double
) async throws {
    let workout = HKWorkout(
        activityType: type,
        start: start,
        end: end,
        duration: end.timeIntervalSince(start),
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
        totalDistance: nil,
        metadata: nil
    )

    try await healthStore.save(workout)
}

// Using workout builder (iOS 17+)
func buildWorkout() async throws {
    let config = HKWorkoutConfiguration()
    config.activityType = .running

    let builder = HKWorkoutBuilder(
        healthStore: healthStore,
        configuration: config,
        device: .local()
    )

    try await builder.beginCollection(at: startDate)

    // Add samples during workout
    let distance = HKQuantity(unit: .mile(), doubleValue: 3.1)
    try await builder.addWorkoutActivity(
        HKWorkoutActivity(
            workoutConfiguration: config,
            start: startDate,
            end: nil,
            metadata: nil
        )
    )

    try await builder.endCollection(at: endDate)
    let workout = try await builder.finishWorkout()
}
```

## Background Delivery

```swift
// Enable in Xcode: Background Modes → HealthKit

func enableBackgroundDelivery() {
    let stepType = HKQuantityType(.stepCount)

    healthStore.enableBackgroundDelivery(
        for: stepType,
        frequency: .hourly
    ) { success, error in
        // Called when new data available
    }
}

// Handle in app delegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    // Re-register observers
}
```

## Common Data Types

```swift
// Quantity types
HKQuantityType(.stepCount)
HKQuantityType(.heartRate)
HKQuantityType(.activeEnergyBurned)
HKQuantityType(.distanceWalkingRunning)
HKQuantityType(.bloodGlucose)
HKQuantityType(.oxygenSaturation)

// Category types
HKCategoryType(.sleepAnalysis)
HKCategoryType(.mindfulSession)

// Characteristic types (read-only)
HKCharacteristicType(.biologicalSex)
HKCharacteristicType(.dateOfBirth)
```

## iOS Version Notes

- iOS 16+: Baseline HealthKit
- iOS 17+: Workout builder improvements
- watchOS: Extended workout APIs

## Gotchas

1. **Can't check auth status** - Privacy; returns "not determined"
2. **Simulator** - No Health app; use device
3. **User controls data** - They can delete or modify
4. **Background needs** - Must re-register observers on launch
5. **Units matter** - Always specify correct HKUnit

## Related

- [carekit.md](carekit.md) - Care plans using health data
- [researchkit.md](researchkit.md) - Research studies with health data
