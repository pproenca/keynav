# Tap to Pay

## Overview

Tap to Pay on iPhone enables merchants to accept contactless payments using iPhone as a payment terminal.

## When to Use

- Merchant/POS applications
- Mobile retail solutions
- Service industry payments

## Basic Setup

```swift
import ProximityReader

class TapToPayManager {
    let reader = PaymentCardReader()

    func prepare() async throws {
        // Check availability
        guard PaymentCardReader.isSupported else {
            throw TapToPayError.notSupported
        }

        // Link account with payment service provider
        try await reader.linkAccount(using: "psp_token")
    }

    func readCard(for amount: Decimal) async throws -> PaymentCardReadResult {
        let request = PaymentCardReadRequest(
            readMode: .amount,
            amount: amount,
            currencyCode: "USD"
        )

        return try await reader.readPaymentCard(request)
    }
}
```

## Requirements

- iPhone XS or newer
- iOS 16.4+
- Payment Service Provider integration
- Apple-approved merchant

## Related

- [apple-pay.md](apple-pay.md) - Consumer payments
