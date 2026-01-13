# Apple Pay

## Overview

Apple Pay enables contactless payments for physical goods and services with Face ID/Touch ID authentication.

## When to Use

- Selling physical goods
- Services requiring payment
- E-commerce checkout
- Donations

## Setup Requirements

```swift
// 1. Enable Apple Pay capability in Xcode
// 2. Create Merchant ID in Apple Developer Portal
// 3. Configure payment processing certificate
// 4. Add merchant ID to entitlements
```

## Check Availability

```swift
import PassKit

func canMakePayments() -> Bool {
    return PKPaymentAuthorizationController.canMakePayments() &&
           PKPaymentAuthorizationController.canMakePayments(
               usingNetworks: [.visa, .masterCard, .amex, .discover]
           )
}
```

## Payment Request

```swift
func createPaymentRequest() -> PKPaymentRequest {
    let request = PKPaymentRequest()

    request.merchantIdentifier = "merchant.com.yourapp"
    request.countryCode = "US"
    request.currencyCode = "USD"
    request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
    request.merchantCapabilities = [.threeDSecure, .debit, .credit]

    // Payment items
    let subtotal = PKPaymentSummaryItem(label: "Subtotal", amount: NSDecimalNumber(string: "99.00"))
    let shipping = PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(string: "5.00"))
    let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "8.32"))
    let total = PKPaymentSummaryItem(label: "Your Company", amount: NSDecimalNumber(string: "112.32"))

    request.paymentSummaryItems = [subtotal, shipping, tax, total]

    return request
}
```

## Present Payment Sheet

```swift
func presentPayment() {
    let request = createPaymentRequest()

    guard let controller = PKPaymentAuthorizationController(paymentRequest: request) else {
        return
    }

    controller.delegate = self
    controller.present { presented in
        if !presented {
            // Handle error
        }
    }
}
```

## Handle Payment

```swift
extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // Send payment.token to your server
        processPayment(payment.token) { result in
            switch result {
            case .success:
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            case .failure(let error):
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
        }
    }

    func paymentAuthorizationControllerDidFinish(
        _ controller: PKPaymentAuthorizationController
    ) {
        controller.dismiss()
    }
}
```

## Shipping Options

```swift
request.requiredShippingContactFields = [.postalAddress, .name, .emailAddress]

request.shippingMethods = [
    PKShippingMethod(label: "Standard", amount: NSDecimalNumber(string: "5.00")),
    PKShippingMethod(label: "Express", amount: NSDecimalNumber(string: "15.00"))
]
request.shippingMethods?[0].identifier = "standard"
request.shippingMethods?[0].detail = "5-7 business days"

// Handle shipping changes
func paymentAuthorizationController(
    _ controller: PKPaymentAuthorizationController,
    didSelectShippingMethod shippingMethod: PKShippingMethod,
    handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void
) {
    // Recalculate total
    let update = PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: updatedItems)
    completion(update)
}
```

## SwiftUI Button

```swift
import PassKit

struct ApplePayButton: UIViewRepresentable {
    var action: () -> Void

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.pay), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKPaymentButton, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        var action: () -> Void
        init(action: @escaping () -> Void) {
            self.action = action
        }
        @objc func pay() {
            action()
        }
    }
}

// Usage
ApplePayButton {
    presentPayment()
}
.frame(height: 50)
```

## Server-Side Processing

```swift
// Payment token structure sent to server:
// payment.token.paymentData - Encrypted payment data
// payment.token.transactionIdentifier - Unique transaction ID
// payment.token.paymentMethod.network - Card network
// payment.token.paymentMethod.type - Debit/credit

// Server must:
// 1. Decrypt payment data with payment processing certificate
// 2. Process with payment processor (Stripe, Braintree, etc.)
// 3. Return success/failure
```

## iOS Version Notes

- iOS 16+: Baseline Apple Pay APIs
- iOS 17+: Enhanced payment sheet customization
- iOS 18+: Tap to Pay improvements

## Gotchas

1. **Certificate setup** - Payment processing certificate must be configured
2. **Testing** - Use sandbox cards in Wallet app
3. **Simulator** - Limited Apple Pay testing; use device
4. **Merchant ID** - Must match exactly in code and entitlements
5. **Regional** - Not available in all countries/regions

## Related

- [storekit.md](storekit.md) - Digital goods purchases
- [tap-to-pay.md](tap-to-pay.md) - Accept Apple Pay as merchant
