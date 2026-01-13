# iCloud

## Overview

iCloud provides data sync across devices via NSUbiquitousKeyValueStore (simple), CloudKit (complex), or document storage.

## When to Use

- Syncing preferences across devices
- Cloud database for app data
- Document storage and sharing
- Cross-device continuity

## Key-Value Storage

```swift
// Simple key-value sync (1MB limit)
let store = NSUbiquitousKeyValueStore.default

// Write
store.set("value", forKey: "preference")
store.set(42, forKey: "count")
store.synchronize()

// Read
let value = store.string(forKey: "preference")
let count = store.longLong(forKey: "count")

// Listen for external changes
NotificationCenter.default.addObserver(
    forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
    object: store, queue: .main
) { notification in
    guard let userInfo = notification.userInfo,
          let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
    else { return }

    switch reason {
    case NSUbiquitousKeyValueStoreQuotaViolationChange:
        // Over quota
        break
    case NSUbiquitousKeyValueStoreAccountChange:
        // iCloud account changed
        break
    case NSUbiquitousKeyValueStoreServerChange:
        // Updated from server
        let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]
        refreshData(keys: keys)
    default:
        break
    }
}
```

## CloudKit Basics

```swift
import CloudKit

// Access containers
let container = CKContainer.default()
let privateDB = container.privateCloudDatabase
let publicDB = container.publicCloudDatabase

// Create record
let record = CKRecord(recordType: "Note")
record["title"] = "My Note"
record["content"] = "Note content"
record["createdAt"] = Date()

// Save
privateDB.save(record) { savedRecord, error in
    if let error = error {
        print("Save failed: \(error)")
    } else {
        print("Saved: \(savedRecord?.recordID)")
    }
}
```

## CloudKit Query

```swift
// Query records
let predicate = NSPredicate(format: "title CONTAINS %@", "search")
let query = CKQuery(recordType: "Note", predicate: predicate)
query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

privateDB.fetch(withQuery: query) { result in
    switch result {
    case .success(let (matchResults, _)):
        for (_, result) in matchResults {
            if case .success(let record) = result {
                print(record["title"])
            }
        }
    case .failure(let error):
        print("Query failed: \(error)")
    }
}
```

## CloudKit Subscriptions

```swift
// Subscribe to changes
let subscription = CKQuerySubscription(
    recordType: "Note",
    predicate: NSPredicate(value: true),
    subscriptionID: "note-changes",
    options: [.firesOnRecordCreation, .firesOnRecordUpdate]
)

let notification = CKSubscription.NotificationInfo()
notification.shouldSendContentAvailable = true
subscription.notificationInfo = notification

privateDB.save(subscription) { _, error in
    if let error = error {
        print("Subscription failed: \(error)")
    }
}
```

## CloudKit Sync with SwiftData (iOS 17+)

```swift
import SwiftData

@Model
class Note {
    var title: String
    var content: String
    var createdAt: Date

    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.createdAt = Date()
    }
}

// Enable CloudKit sync
let config = ModelConfiguration(cloudKitDatabase: .private("iCloud.com.app.container"))
let container = try ModelContainer(for: Note.self, configurations: config)
```

## Check iCloud Status

```swift
// Check account status
CKContainer.default().accountStatus { status, error in
    switch status {
    case .available:
        // iCloud available
        break
    case .noAccount:
        // Not signed in
        break
    case .restricted:
        // Parental controls
        break
    case .couldNotDetermine:
        // Check failed
        break
    case .temporarilyUnavailable:
        // Try again later
        break
    @unknown default:
        break
    }
}
```

## Document Storage

```swift
// iCloud Documents folder
let fileManager = FileManager.default
if let containerURL = fileManager.url(
    forUbiquityContainerIdentifier: nil
)?.appendingPathComponent("Documents") {
    // Use containerURL for document storage
}

// UIDocument for automatic conflict resolution
class MyDocument: UIDocument {
    var content: Data?

    override func contents(forType typeName: String) throws -> Any {
        return content ?? Data()
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        content = contents as? Data
    }
}
```

## iOS Version Notes

- iOS 16+: Baseline CloudKit
- iOS 17+: SwiftData CloudKit integration
- iOS 18+: Enhanced sync performance

## Gotchas

1. **KV Store limits** - 1MB total, 1024 keys, ~64KB per key
2. **CloudKit quotas** - Free tier has limits; monitor usage
3. **Offline support** - CloudKit needs network; cache locally
4. **Account changes** - Handle iCloud account sign-out
5. **Entitlements** - Enable iCloud capability in Xcode

## Related

- [sign-in-apple.md](sign-in-apple.md) - iCloud uses Apple ID
- [siri.md](siri.md) - Siri can access iCloud data
