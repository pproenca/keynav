# Sign in with Apple

## Overview

Sign in with Apple provides secure, privacy-focused authentication. Required for apps with third-party sign-in options.

## When to Use

- User authentication
- When app has any third-party sign-in (Google, Facebook, etc.)
- Privacy-focused authentication needs

## SwiftUI Implementation

```swift
import AuthenticationServices

struct SignInView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
            request.nonce = generateNonce()
        } onCompletion: { result in
            handleSignIn(result)
        }
        .signInWithAppleButtonStyle(
            colorScheme == .dark ? .white : .black
        )
        .frame(height: 50)
    }

    func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userID = credential.user
                let email = credential.email
                let fullName = credential.fullName

                // Identity token for server verification
                if let token = credential.identityToken,
                   let tokenString = String(data: token, encoding: .utf8) {
                    sendToServer(userID: userID, token: tokenString)
                }
            }
        case .failure(let error):
            print("Sign in failed: \(error)")
        }
    }
}
```

## Check Credential State

```swift
func checkCredentialState(userID: String) {
    let provider = ASAuthorizationAppleIDProvider()

    provider.getCredentialState(forUserID: userID) { state, error in
        switch state {
        case .authorized:
            // User is signed in
            break
        case .revoked:
            // User revoked authorization
            signOut()
        case .notFound:
            // No credential found
            showSignIn()
        case .transferred:
            // Account transferred to different device
            break
        @unknown default:
            break
        }
    }
}
```

## Nonce Generation

```swift
import CryptoKit

func generateNonce() -> String {
    let nonce = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
    return nonce.map { String(format: "%02x", $0) }.joined()
}

func sha256(_ input: String) -> String {
    let data = Data(input.utf8)
    let hash = SHA256.hash(data: data)
    return hash.map { String(format: "%02x", $0) }.joined()
}
```

## UIKit Implementation

```swift
class SignInViewController: UIViewController {
    func setupSignInButton() {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc func handleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        // Handle success
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        // Handle error
    }
}
```

## Server-Side Verification

```swift
// Send to your server
struct AppleSignInRequest: Codable {
    let userIdentifier: String
    let identityToken: String
    let authorizationCode: String?
    let fullName: PersonNameComponents?
    let email: String?
}

// Server should:
// 1. Verify identityToken with Apple's public keys
// 2. Check nonce matches
// 3. Extract claims from JWT
// 4. Create/update user account
```

## Revocation Notification

```swift
// App Delegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    NotificationCenter.default.addObserver(
        forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
        object: nil, queue: .main
    ) { _ in
        // User revoked Sign in with Apple
        signOutUser()
    }
}
```

## Keychain Storage

```swift
// Store user identifier securely
func saveUserID(_ userID: String) {
    let data = userID.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "appleUserID",
        kSecValueData as String: data
    ]
    SecItemAdd(query as CFDictionary, nil)
}
```

## iOS Version Notes

- iOS 16+: Baseline Sign in with Apple
- iOS 17+: Passkey integration option
- Required since iOS 13 for apps with third-party auth

## Gotchas

1. **Email/name only on first sign-in** - Store immediately; won't be provided again
2. **User can hide email** - Handle relay addresses (@privaterelay.appleid.com)
3. **Required for App Store** - If you have Google/Facebook sign-in, must have Apple
4. **Token expiration** - Identity token expires; refresh on server
5. **User deletion** - Provide way to delete account per App Store guidelines

## Related

- [icloud.md](icloud.md) - iCloud data associated with Apple ID
- [siri.md](siri.md) - Personalized Siri with sign-in
