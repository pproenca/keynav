# ResearchKit

## Overview

ResearchKit enables building medical research apps with consent, surveys, and active tasks.

## When to Use

- Clinical research studies
- Medical surveys
- Active task assessments
- Consent workflows

## Consent Flow

```swift
import ResearchKit

func createConsentDocument() -> ORKConsentDocument {
    let document = ORKConsentDocument()
    document.title = "Study Consent"

    // Add sections
    let sections = [
        ORKConsentSection(type: .overview),
        ORKConsentSection(type: .dataGathering),
        ORKConsentSection(type: .privacy),
        ORKConsentSection(type: .studySurvey)
    ]

    sections[0].summary = "Study overview..."
    document.sections = sections

    // Signature
    let signature = ORKConsentSignature(
        forPersonWithTitle: "Participant",
        dateFormatString: nil,
        identifier: "participant"
    )
    document.addSignature(signature)

    return document
}

// Present consent
let step = ORKVisualConsentStep(identifier: "consent", document: consentDocument)
let task = ORKOrderedTask(identifier: "consentTask", steps: [step])
let vc = ORKTaskViewController(task: task, taskRun: nil)
present(vc, animated: true)
```

## Survey Tasks

```swift
let questionStep = ORKQuestionStep(
    identifier: "painLevel",
    title: "Pain Level",
    question: "Rate your pain on a scale of 1-10",
    answer: ORKScaleAnswerFormat(
        maximumValue: 10,
        minimumValue: 1,
        defaultValue: 5,
        step: 1
    )
)

let task = ORKOrderedTask(identifier: "survey", steps: [questionStep])
```

## Active Tasks

```swift
// Built-in active tasks
let walkingTask = ORKOrderedTask.fitnessCheck(
    withIdentifier: "fitness",
    intendedUseDescription: "Measure your walking ability",
    walkDuration: 360,
    restDuration: 60,
    options: []
)

// Tapping task
let tappingTask = ORKOrderedTask.twoFingerTappingIntervalTask(
    withIdentifier: "tapping",
    intendedUseDescription: "Measure dexterity",
    duration: 20,
    handOptions: [.both],
    options: []
)
```

## Related

- [healthkit.md](healthkit.md) - Health data collection
- [carekit.md](carekit.md) - Care management
