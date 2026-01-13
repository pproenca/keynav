# NFC

## Overview

Core NFC enables reading and writing NFC tags (NDEF format).

## When to Use

- Reading NFC tags
- Writing NFC data
- Background tag reading
- Tag authentication

## Read Tags

```swift
import CoreNFC

class NFCManager: NSObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?

    func startReading() {
        guard NFCNDEFReaderSession.readingAvailable else { return }

        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session?.alertMessage = "Hold iPhone near tag"
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                let payload = String(data: record.payload.dropFirst(), encoding: .utf8)
                print("Read: \(payload ?? "")")
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Handle error
    }
}
```

## Write Tags

```swift
func writeTag(session: NFCNDEFReaderSession, tag: NFCNDEFTag, message: String) {
    let payload = NFCNDEFPayload(
        format: .nfcWellKnown,
        type: "T".data(using: .utf8)!,
        identifier: Data(),
        payload: message.data(using: .utf8)!
    )

    let ndefMessage = NFCNDEFMessage(records: [payload])

    tag.writeNDEF(ndefMessage) { error in
        if let error = error {
            session.alertMessage = "Write failed"
        } else {
            session.alertMessage = "Success!"
        }
        session.invalidate()
    }
}
```

## Background Reading

```swift
// Info.plist
// Add: com.apple.developer.nfc.readersession.formats = TAG
// User taps tag → app launches automatically
```

## Related

- [homekit.md](homekit.md) - NFC triggers for home automation
