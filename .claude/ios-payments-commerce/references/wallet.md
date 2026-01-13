# Wallet

## Overview

Wallet stores passes for boarding passes, tickets, loyalty cards, and coupons.

## When to Use

- Event tickets
- Boarding passes
- Loyalty/membership cards
- Store coupons

## Pass Creation

```swift
// Passes are created server-side with .pkpass files
// Server generates signed pass bundles

// Add pass from app
import PassKit

func addPass(from url: URL) {
    guard let passData = try? Data(contentsOf: url),
          let pass = try? PKPass(data: passData)
    else { return }

    let library = PKPassLibrary()

    if library.containsPass(pass) {
        // Already added
    } else {
        let controller = PKAddPassesViewController(pass: pass)
        present(controller, animated: true)
    }
}
```

## Check Pass Status

```swift
let library = PKPassLibrary()

// Check if Wallet available
if PKPassLibrary.isPassLibraryAvailable() {
    // List passes
    let passes = library.passes()
    for pass in passes {
        print("\(pass.localizedName): \(pass.passTypeIdentifier)")
    }
}
```

## Related

- [apple-pay.md](apple-pay.md) - Payment cards in Wallet
