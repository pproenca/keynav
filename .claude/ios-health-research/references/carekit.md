# CareKit

## Overview

CareKit helps build apps for care management with tasks, contacts, and outcome tracking.

## When to Use

- Patient care apps
- Medication reminders
- Symptom tracking
- Care coordination

## Basic Setup

```swift
import CareKit
import CareKitStore

let store = OCKStore(name: "MyCareStore", type: .onDisk)

// Add a task
var task = OCKTask(
    id: "medication",
    title: "Take Medication",
    carePlanUUID: nil,
    schedule: .dailyAtTime(hour: 8, minutes: 0, start: Date(), end: nil)
)

try await store.addTask(task)
```

## Care Plan View

```swift
import CareKitUI

struct CareView: View {
    @StateObject var viewModel = CareViewModel()

    var body: some View {
        List {
            InstructionsTaskView(
                task: viewModel.medicationTask,
                eventQuery: .init(for: Date()),
                storeManager: viewModel.storeManager
            )
        }
    }
}
```

## Track Outcomes

```swift
// Record task completion
let outcome = OCKOutcome(
    taskUUID: task.uuid,
    taskOccurrenceIndex: 0,
    values: [OCKOutcomeValue(true)]
)

try await store.addOutcome(outcome)
```

## Related

- [healthkit.md](healthkit.md) - Health data integration
- [researchkit.md](researchkit.md) - Research studies
