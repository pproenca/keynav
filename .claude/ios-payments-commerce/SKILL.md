---
name: ios-payments-commerce
description: |
  iOS payments and commerce frameworks. Covers Apple Pay for contactless payments,
  StoreKit 2 for in-app purchases and subscriptions, Tap to Pay for merchant
  contactless payments, Wallet for passes and tickets, and ID Verifier for identity
  verification. Use this skill when: (1) Implementing Apple Pay, (2) Adding
  subscriptions or in-app purchases, (3) Building merchant payment apps, (4)
  Creating Wallet passes, (5) Verifying user identity, (6) User asks about "Apple
  Pay", "in-app purchase", "subscription", "StoreKit", "Wallet", "pass", "Tap to
  Pay", "payment", "commerce".
---

# iOS Payments & Commerce

Payment processing and commerce features for iOS apps.

## Quick Decision Tree

```
Type of payment?
├── User pays app → StoreKit 2 (in-app purchase)
├── User pays merchant (your app) → Apple Pay
├── Accept contactless (merchant) → Tap to Pay
└── Tickets/passes → Wallet

StoreKit product type?
├── One-time → Non-consumable or Consumable
├── Recurring → Auto-renewable subscription
└── Timed access → Non-renewing subscription
```

## Quick Start - StoreKit 2

```swift
import StoreKit

// Fetch products
let products = try await Product.products(for: ["premium_monthly", "premium_yearly"])

// Purchase
let result = try await product.purchase()

switch result {
case .success(let verification):
    let transaction = try checkVerified(verification)
    await transaction.finish()
    unlockPremium()

case .userCancelled:
    break

case .pending:
    // Needs approval (Ask to Buy)
    break

@unknown default:
    break
}
```

## Quick Start - Apple Pay

```swift
import PassKit

let request = PKPaymentRequest()
request.merchantIdentifier = "merchant.com.example"
request.countryCode = "US"
request.currencyCode = "USD"
request.supportedNetworks = [.visa, .masterCard, .amex]
request.merchantCapabilities = .threeDSecure

request.paymentSummaryItems = [
    PKPaymentSummaryItem(label: "Product", amount: 9.99),
    PKPaymentSummaryItem(label: "My Store", amount: 9.99)
]

let controller = PKPaymentAuthorizationController(paymentRequest: request)
controller.delegate = self
controller.present()
```

## Reference Files

- **Apple Pay**: See [references/apple-pay.md](references/apple-pay.md) - Payment setup, validation
- **StoreKit**: See [references/storekit.md](references/storekit.md) - Products, subscriptions, receipts
- **Tap to Pay**: See [references/tap-to-pay.md](references/tap-to-pay.md) - Merchant setup
- **Wallet**: See [references/wallet.md](references/wallet.md) - Pass creation, updates
- **ID Verifier**: See [references/id-verifier.md](references/id-verifier.md) - Identity verification

## Common Gotchas

1. **Sandbox testing** - Use sandbox accounts, not real cards
2. **Transaction finishing** - Always call `transaction.finish()`
3. **Receipt validation** - Validate on server for subscriptions
4. **Merchant ID** - Must be configured in Apple Developer Portal
5. **Regional availability** - Apple Pay not available everywhere
