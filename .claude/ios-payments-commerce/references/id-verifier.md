# ID Verifier

## Overview

ID Verifier allows apps to verify user identity using IDs stored in Wallet (driver's license, state ID).

## When to Use

- Age verification
- Identity confirmation
- KYC compliance

## Basic Flow

```swift
import ProximityReader

// Request identity verification
func verifyIdentity() async throws {
    let request = IdentityDocumentReadRequest(
        elements: [.age, .portrait, .givenName, .familyName]
    )

    let reader = IdentityDocumentReader()
    let result = try await reader.readDocument(request)

    // Check result
    if let age = result.age {
        let isOver21 = age >= 21
    }
}
```

## Requirements

- iOS 17+
- iPhone XS or newer
- User has ID in Wallet
- Merchant approval from Apple

## Privacy

- Only request minimum data needed
- User explicitly approves each request
- Data is encrypted and attestable

## Related

- [wallet.md](wallet.md) - IDs stored in Wallet
