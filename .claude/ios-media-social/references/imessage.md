# iMessage Apps

## Overview

iMessage apps extend Messages with interactive content, stickers, and custom experiences.

## When to Use

- Sticker packs
- Interactive messages
- Collaborative content
- Message extensions

## Sticker Pack (No Code)

```
// Create Sticker Pack Application target in Xcode
// Add images to Stickers.xcstickers

// Supported formats:
// - PNG, APNG, GIF, JPEG
// - Small: 100x100 pt
// - Medium: 136x136 pt
// - Large: 206x206 pt
```

## iMessage Extension

```swift
import Messages

class MessagesViewController: MSMessagesAppViewController {

    override func willBecomeActive(with conversation: MSConversation) {
        // Called when extension becomes active
        presentContent(for: conversation)
    }

    override func didResignActive(with conversation: MSConversation) {
        // Called when extension becomes inactive
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Received a message
    }

    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        // User tapped on message
    }

    func presentContent(for conversation: MSConversation) {
        // Set up UI based on presentation style
        switch presentationStyle {
        case .compact:
            showCompactUI()
        case .expanded:
            showExpandedUI()
        case .transcript:
            showTranscriptUI()
        @unknown default:
            break
        }
    }
}
```

## Send Message

```swift
func sendMessage() {
    guard let conversation = activeConversation else { return }

    let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
    let layout = MSMessageTemplateLayout()

    layout.image = UIImage(named: "preview")
    layout.caption = "Check this out!"
    layout.subcaption = "Tap to open"

    message.layout = layout

    // Store data in URL
    var components = URLComponents()
    components.queryItems = [
        URLQueryItem(name: "id", value: itemID),
        URLQueryItem(name: "data", value: encodedData)
    ]
    message.url = components.url

    conversation.insert(message) { error in
        if let error = error {
            print("Send failed: \(error)")
        }
    }
}
```

## Interactive Message

```swift
// Parse message data
func parseMessage(_ message: MSMessage) -> MyData? {
    guard let url = message.url,
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems
    else { return nil }

    var data = MyData()
    for item in queryItems {
        switch item.name {
        case "id": data.id = item.value
        case "data": data.content = item.value
        default: break
        }
    }
    return data
}

// Update existing message
func updateMessage(_ message: MSMessage) {
    guard let conversation = activeConversation else { return }

    let newMessage = MSMessage(session: message.session ?? MSSession())
    // Configure new message...

    conversation.insert(newMessage) { error in }
}
```

## Request Expanded Mode

```swift
func showFullScreen() {
    requestPresentationStyle(.expanded)
}

override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    // Prepare for transition
}

override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    // Update UI for new style
}
```

## Live Message Layout

```swift
// For live-updating content
class LiveMessageLayout: MSMessageLiveLayout {
    override var alternateLayout: MSMessageTemplateLayout {
        let layout = MSMessageTemplateLayout()
        layout.caption = "Tap to view live content"
        return layout
    }
}
```

## Related

- [shareplay.md](shareplay.md) - Share content in FaceTime
- [game-center.md](game-center.md) - Multiplayer in Messages
