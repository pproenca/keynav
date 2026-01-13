# Keyboard

## Overview

iOS keyboard handling includes software keyboard management, hardware keyboard shortcuts, and text input customization.

## When to Use

- Managing keyboard appearance
- Implementing keyboard shortcuts
- Customizing text input
- Handling keyboard avoidance

## Keyboard Avoidance

```swift
// SwiftUI handles automatically in ScrollView
ScrollView {
    VStack {
        TextField("Name", text: $name)
        TextField("Email", text: $email)
    }
}

// Manual adjustment
.padding(.bottom, keyboardHeight)
.animation(.easeOut, value: keyboardHeight)
```

## Dismiss Keyboard

```swift
// Tap outside to dismiss
.onTapGesture {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil, from: nil, for: nil
    )
}

// Scroll to dismiss
ScrollView {
    // content
}
.scrollDismissesKeyboard(.interactively)  // or .immediately

// Focus state
@FocusState private var isFocused: Bool

TextField("Input", text: $text)
    .focused($isFocused)

Button("Done") {
    isFocused = false
}
```

## Keyboard Toolbar

```swift
TextField("Amount", text: $amount)
    .keyboardType(.decimalPad)
    .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                isFocused = false
            }
        }
    }
```

## Keyboard Types

```swift
TextField("Email", text: $email)
    .keyboardType(.emailAddress)

// Available types:
// .default
// .asciiCapable
// .numbersAndPunctuation
// .URL
// .numberPad
// .phonePad
// .namePhonePad
// .emailAddress
// .decimalPad
// .twitter
// .webSearch
// .asciiCapableNumberPad
```

## Text Content Type

```swift
TextField("Email", text: $email)
    .textContentType(.emailAddress)

// Common content types:
// .name, .givenName, .familyName
// .emailAddress
// .telephoneNumber
// .streetAddressLine1, .city, .postalCode
// .password, .newPassword
// .oneTimeCode
// .creditCardNumber
```

## Autocorrect and Capitalization

```swift
TextField("Username", text: $username)
    .autocorrectionDisabled()
    .textInputAutocapitalization(.never)

// Capitalization options:
// .never
// .words
// .sentences
// .characters
```

## Keyboard Shortcuts

```swift
// Button shortcut
Button("Save") { save() }
    .keyboardShortcut("s", modifiers: .command)

// Default action (Return key)
Button("Submit") { submit() }
    .keyboardShortcut(.defaultAction)

// Cancel action (Escape)
Button("Cancel") { cancel() }
    .keyboardShortcut(.cancelAction)

// Custom modifiers
.keyboardShortcut("p", modifiers: [.command, .shift])
```

## Key Press Handling (iOS 17+)

```swift
TextField("Input", text: $text)
    .onKeyPress(.return) {
        submit()
        return .handled
    }
    .onKeyPress(.escape) {
        cancel()
        return .handled
    }
    .onKeyPress(characters: .alphanumerics) { press in
        print("Pressed: \(press.characters)")
        return .ignored  // Let it through
    }
```

## Secure Text Entry

```swift
SecureField("Password", text: $password)
    .textContentType(.password)

// Toggle visibility
@State private var showPassword = false

Group {
    if showPassword {
        TextField("Password", text: $password)
    } else {
        SecureField("Password", text: $password)
    }
}
.textContentType(.password)
```

## Submit Label

```swift
TextField("Search", text: $query)
    .submitLabel(.search)
    .onSubmit {
        performSearch()
    }

// Available labels:
// .done, .go, .send, .join
// .route, .search, .return
// .next, .continue
```

## Input Accessory View (UIKit)

```swift
// For complex custom toolbars, use UIKit
struct KeyboardAccessoryTextField: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.inputAccessoryView = createToolbar()
        return textField
    }

    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        ]
        toolbar.sizeToFit()
        return toolbar
    }
}
```

## iOS Version Notes

- iOS 16+: Baseline keyboard APIs
- iOS 17+: `onKeyPress` modifier, improved shortcuts
- iOS 18+: Enhanced input methods

## Gotchas

1. **Keyboard height** - Use NotificationCenter for precise height
2. **Hardware keyboard** - Test shortcuts with physical keyboard
3. **Secure field limitations** - Can't show/hide same field easily
4. **Content type conflicts** - Wrong content type breaks autofill
5. **iPad keyboard** - Can be undocked/split; handle gracefully

## Related

- [gestures.md](gestures.md) - Tap to dismiss patterns
- [focus-selection.md](focus-selection.md) - Focus and tab navigation
