# Generative AI

## Overview

Apple Intelligence provides on-device generative AI capabilities for text, images, and more.

## When to Use

- Text generation/summarization
- Writing assistance
- Image generation (Image Playground)
- Intelligent suggestions

## Writing Tools

```swift
// System-provided writing tools
// Available automatically in text views

// Custom integration
import UIKit

// Enable Writing Tools
textView.writingToolsBehavior = .default

// Writing Tools delegate
extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, writingToolsIgnoredRangesInEnclosingRange enclosingRange: NSRange) -> [NSValue] {
        // Return ranges to exclude from writing tools
        return []
    }
}
```

## App Intents with AI

```swift
import AppIntents

struct SummarizeIntent: AppIntent {
    static var title: LocalizedStringResource = "Summarize"

    @Parameter(title: "Text")
    var text: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // System handles AI processing
        return .result(value: summarizedText)
    }
}
```

## Image Playground (iOS 18+)

```swift
// Present Image Playground
import ImagePlayground

func showImagePlayground() {
    let config = ImagePlaygroundConfiguration()
    config.concepts = [
        .text("A sunset over mountains"),
        .extractedFrom(sourceImage)
    ]

    let controller = ImagePlaygroundViewController(configuration: config)
    controller.delegate = self
    present(controller, animated: true)
}
```

## Privacy Considerations

```swift
// All processing happens on-device
// Data never leaves the device
// No cloud AI services required

// Check availability
if #available(iOS 18.0, *) {
    // Apple Intelligence available
}
```

## Related

- [coreml.md](coreml.md) - Custom ML models
- [siri.md](../ios-platform-integration/references/siri.md) - Voice AI
