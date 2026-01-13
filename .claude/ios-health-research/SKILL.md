---
name: ios-health-research
description: |
  iOS health and medical research frameworks. Covers HealthKit for reading/writing
  health and fitness data (steps, heart rate, workouts), CareKit for care plans
  and symptom tracking, and ResearchKit for building medical research studies with
  surveys and consent. Use this skill when: (1) Building health or fitness apps,
  (2) Accessing Health app data, (3) Tracking workouts or exercises, (4)
  Implementing care plans, (5) Building research study apps, (6) User asks about
  "HealthKit", "health data", "fitness", "workout", "steps", "heart rate",
  "CareKit", "care plan", "ResearchKit", "medical research", "survey".
---

# iOS Health & Research

Health data, fitness tracking, and medical research frameworks.

## Privacy First

Health data is highly sensitive. Always:
- Request only necessary permissions
- Explain why data is needed
- Handle data securely
- Allow users to revoke access

## Quick Start - HealthKit

```swift
import HealthKit

let healthStore = HKHealthStore()

// Check availability
guard HKHealthStore.isHealthDataAvailable() else { return }

// Request authorization
let readTypes: Set<HKObjectType> = [
    HKQuantityType(.stepCount),
    HKQuantityType(.heartRate),
    HKObjectType.workoutType()
]

let writeTypes: Set<HKSampleType> = [
    HKQuantityType(.stepCount)
]

try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)

// Read step count
let stepType = HKQuantityType(.stepCount)
let predicate = HKQuery.predicateForSamples(
    withStart: Calendar.current.startOfDay(for: Date()),
    end: Date()
)

let query = HKStatisticsQuery(
    quantityType: stepType,
    quantitySamplePredicate: predicate,
    options: .cumulativeSum
) { _, result, _ in
    let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
    print("Steps today: \(Int(steps))")
}

healthStore.execute(query)
```

## Quick Start - Workout

```swift
// Start workout session
let configuration = HKWorkoutConfiguration()
configuration.activityType = .running
configuration.locationType = .outdoor

let builder = HKWorkoutBuilder(
    healthStore: healthStore,
    configuration: configuration,
    device: .local()
)

try await builder.beginCollection(at: Date())

// End workout
try await builder.endCollection(at: Date())
let workout = try await builder.finishWorkout()
```

## Reference Files

- **HealthKit**: See [references/healthkit.md](references/healthkit.md) - Data types, queries, workouts
- **CareKit**: See [references/carekit.md](references/carekit.md) - Care plans, tasks, charts
- **ResearchKit**: See [references/researchkit.md](references/researchkit.md) - Consent, surveys, tasks

## Common Gotchas

1. **Authorization is per-type** - User can grant partial access
2. **Can't check authorization status** - Privacy; assume not authorized
3. **Background delivery** - Requires specific configuration
4. **Simulator** - No Health app; test on device
5. **HIPAA considerations** - Medical apps may need compliance
