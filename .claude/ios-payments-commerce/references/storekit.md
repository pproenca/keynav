# StoreKit

## Overview

StoreKit 2 provides modern, Swift-first APIs for in-app purchases and subscriptions with built-in transaction management.

## When to Use

- Selling digital content
- Subscription services
- Consumable items (coins, credits)
- Premium features

## Product Configuration

```swift
import StoreKit

// Product IDs from App Store Connect
let productIDs = [
    "com.app.premium_monthly",
    "com.app.premium_yearly",
    "com.app.coins_100"
]

// Fetch products
func fetchProducts() async throws -> [Product] {
    return try await Product.products(for: productIDs)
}

// Product types
// .consumable - Can be purchased multiple times
// .nonConsumable - One-time purchase
// .autoRenewable - Subscription
// .nonRenewable - Time-limited access
```

## Purchase Flow

```swift
func purchase(_ product: Product) async throws {
    let result = try await product.purchase()

    switch result {
    case .success(let verification):
        let transaction = try checkVerified(verification)

        // Deliver content
        await deliverProduct(for: transaction)

        // CRITICAL: Finish transaction
        await transaction.finish()

    case .userCancelled:
        // User cancelled
        break

    case .pending:
        // Requires approval (Ask to Buy)
        break

    @unknown default:
        break
    }
}

func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .verified(let safe):
        return safe
    case .unverified:
        throw StoreError.verificationFailed
    }
}
```

## Transaction Observer

```swift
// Listen for transactions (purchases, renewals, refunds)
func observeTransactions() -> Task<Void, Never> {
    Task.detached {
        for await result in Transaction.updates {
            do {
                let transaction = try self.checkVerified(result)

                // Handle transaction
                await self.handleTransaction(transaction)

                await transaction.finish()
            } catch {
                // Verification failed
            }
        }
    }
}

// Start on app launch
@main
struct MyApp: App {
    let transactionObserver = observeTransactions()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Subscription Management

```swift
// Check subscription status
func checkSubscription() async -> Bool {
    for await result in Transaction.currentEntitlements {
        if case .verified(let transaction) = result {
            if transaction.productType == .autoRenewable {
                return transaction.revocationDate == nil
            }
        }
    }
    return false
}

// Subscription status
let statuses = try await Product.SubscriptionInfo.status(for: "premium_group")

for status in statuses {
    switch status.state {
    case .subscribed:
        // Active subscription
        break
    case .expired:
        // Subscription expired
        break
    case .inBillingRetryPeriod:
        // Payment issue, still active
        break
    case .inGracePeriod:
        // Grace period active
        break
    case .revoked:
        // Refunded
        break
    default:
        break
    }
}
```

## Restore Purchases

```swift
// Sync with App Store
func restorePurchases() async throws {
    try await AppStore.sync()

    // Check entitlements
    for await result in Transaction.currentEntitlements {
        if case .verified(let transaction) = result {
            await deliverProduct(for: transaction)
        }
    }
}
```

## Offer Codes and Promotions

```swift
// Redeem offer code
try await AppStore.presentOfferCodeRedeemSheet()

// Promotional offers (require signature from server)
let offer = Product.PurchaseOption.promotionalOffer(
    offerID: "holiday_discount",
    keyID: "KEY_ID",
    nonce: UUID(),
    signature: Data(signatureFromServer),
    timestamp: timestamp
)

try await product.purchase(options: [offer])
```

## SwiftUI Integration

```swift
import StoreKit

struct StoreView: View {
    @State private var products: [Product] = []

    var body: some View {
        List(products) { product in
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                    Text(product.description)
                        .font(.caption)
                }
                Spacer()
                Button(product.displayPrice) {
                    Task { try await purchase(product) }
                }
            }
        }
        .task { products = try? await fetchProducts() ?? [] }
    }
}

// Built-in store views
ProductView(id: "com.app.premium") {
    Image(systemName: "star")
}

SubscriptionStoreView(groupID: "premium_group")
```

## iOS Version Notes

- iOS 15+: StoreKit 2 APIs
- iOS 16+: SwiftUI ProductView
- iOS 17+: SubscriptionStoreView

## Gotchas

1. **Always finish transactions** - Unfinished transactions block future purchases
2. **Test in Sandbox** - Use sandbox accounts in Settings
3. **Server validation** - Validate receipts server-side for security
4. **Subscription groups** - User can only have one active subscription per group
5. **Ask to Buy** - Handle pending transactions for family accounts

## Related

- [apple-pay.md](apple-pay.md) - Physical goods payments
- [wallet.md](wallet.md) - Store receipts as passes
