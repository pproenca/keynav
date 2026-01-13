# Siri

## Overview

App Intents framework enables Siri integration, Shortcuts support, and Spotlight actions. Replaces legacy SiriKit for most use cases.

## When to Use

- Adding Siri voice commands
- Creating Shortcuts automations
- Spotlight quick actions
- Focus filters

## Basic App Intent

```swift
import AppIntents

struct StartWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Workout"
    static var description = IntentDescription("Starts a workout session")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        WorkoutManager.shared.startWorkout()
        return .result()
    }
}
```

## Intent with Parameters

```swift
struct SendMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Message"

    @Parameter(title: "Recipient")
    var recipient: String

    @Parameter(title: "Message")
    var message: String

    static var parameterSummary: some ParameterSummary {
        Summary("Send '\(\.$message)' to \(\.$recipient)")
    }

    func perform() async throws -> some IntentResult {
        await MessageService.send(message, to: recipient)
        return .result(dialog: "Message sent to \(recipient)")
    }
}
```

## Entity Parameters

```swift
// Define entity
struct ProjectEntity: AppEntity {
    var id: String
    var name: String

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Project")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static var defaultQuery = ProjectQuery()
}

// Query for entities
struct ProjectQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ProjectEntity] {
        return ProjectStore.projects(for: identifiers)
    }

    func suggestedEntities() async throws -> [ProjectEntity] {
        return ProjectStore.recentProjects
    }
}

// Use in intent
struct OpenProjectIntent: AppIntent {
    @Parameter(title: "Project")
    var project: ProjectEntity

    func perform() async throws -> some IntentResult {
        await open(project)
        return .result()
    }
}
```

## Shortcuts Integration

```swift
struct MyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartWorkoutIntent(),
            phrases: [
                "Start a workout with \(.applicationName)",
                "Begin exercising in \(.applicationName)"
            ],
            shortTitle: "Start Workout",
            systemImageName: "figure.run"
        )
    }
}
```

## Dialog and Results

```swift
func perform() async throws -> some IntentResult & ReturnsValue<Int> {
    let count = await processItems()
    return .result(
        value: count,
        dialog: "Processed \(count) items"
    )
}

// Show view result
func perform() async throws -> some IntentResult & ShowsSnippetView {
    return .result {
        ResultView(data: processedData)
    }
}
```

## Intent Configuration

```swift
// Run in background (no app launch)
static var openAppWhenRun: Bool = false

// Confirmation required
func perform() async throws -> some IntentResult {
    try await requestConfirmation(result: .result(dialog: "Delete all items?"))
    await deleteAll()
    return .result(dialog: "Deleted")
}
```

## Focus Filter

```swift
struct WorkFocusFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Work Mode"

    @Parameter(title: "Show Work Projects Only")
    var workOnly: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Work Mode: \(workOnly ? "On" : "Off")")
    }

    func perform() async throws -> some IntentResult {
        Settings.workModeEnabled = workOnly
        return .result()
    }
}
```

## iOS Version Notes

- iOS 16+: App Intents framework (recommended)
- iOS 17+: Interactive widgets with intents
- iOS 18+: Enhanced Apple Intelligence integration

## Gotchas

1. **Phrases must be unique** - No overlap with other apps
2. **Entity queries** - Must return quickly for good UX
3. **Background limits** - Background intents have time constraints
4. **Testing** - Use Shortcuts app to test intents
5. **Localization** - Use LocalizedStringResource for all strings

## Related

- [sign-in-apple.md](sign-in-apple.md) - Authentication intents
- [icloud.md](icloud.md) - Data sync for intent parameters
