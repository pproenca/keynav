# Releasing KeyNav

Releases are fully automated via GitHub Actions. When you push a version tag, the workflow will:

1. Build the app
2. Sign with Developer ID
3. Notarize with Apple
4. Create a DMG
5. Update the Sparkle appcast
6. Create a GitHub Release

## One-Time Setup

### 1. Configure GitHub Secrets

Go to your repository **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

| Secret Name | Description | How to Get It |
|-------------|-------------|---------------|
| `SIGNING_IDENTITY` | Developer ID signing identity | `Developer ID Application: Pedro Moreira Proença (X7A5P2XW9X)` |
| `DEVELOPER_ID_CERTIFICATE_P12` | Base64-encoded .p12 certificate | See "Export Certificate" below |
| `DEVELOPER_ID_CERTIFICATE_PASSWORD` | Password for the .p12 file | Password you set when exporting |
| `APPLE_ID` | Your Apple ID email | Your Apple Developer account email |
| `APPLE_ID_PASSWORD` | App-specific password | [appleid.apple.com](https://appleid.apple.com) → App-Specific Passwords |
| `TEAM_ID` | Apple Developer Team ID | `X7A5P2XW9X` |
| `SPARKLE_PRIVATE_KEY` | EdDSA private key for Sparkle | See "Export Sparkle Key" below |

### 2. Export Developer ID Certificate

1. Open **Keychain Access**
2. Find "Developer ID Application: Pedro Moreira Proença"
3. Right-click → **Export**
4. Save as `.p12` file with a strong password
5. Convert to base64:
   ```bash
   base64 -i certificate.p12 | pbcopy
   ```
6. Paste into `DEVELOPER_ID_CERTIFICATE_P12` secret
7. Delete the .p12 file

### 3. Export Sparkle Private Key

```bash
.build/artifacts/sparkle/Sparkle/bin/generate_keys -x /tmp/sparkle_key.txt
cat /tmp/sparkle_key.txt | pbcopy
rm /tmp/sparkle_key.txt
```

Paste into `SPARKLE_PRIVATE_KEY` secret.

### 4. Enable GitHub Pages

1. Go to repository **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: `master`, Folder: `/docs`
4. Save

## Creating a Release

### 1. Bump Version

Edit `Sources/KeyNav/Resources/Info.plist`:
- `CFBundleShortVersionString`: User-visible version (e.g., `0.2.0`)
- `CFBundleVersion`: Build number (increment each release, e.g., `2`)

### 2. Commit and Tag

```bash
git add Sources/KeyNav/Resources/Info.plist
git commit -m "Bump version to 0.2.0"
git tag v0.2.0
git push origin master --tags
```

### 3. Monitor

The release workflow will run automatically. Check progress at:
**Actions** → **Release** workflow

Once complete:
- DMG available at GitHub Releases
- Appcast updated automatically
- Users will see update in-app

## Troubleshooting

### Notarization fails
- Check `APPLE_ID` and `APPLE_ID_PASSWORD` secrets
- Ensure app-specific password is valid (regenerate if needed)

### Signing fails
- Verify certificate is exported correctly
- Check `DEVELOPER_ID_CERTIFICATE_PASSWORD` matches export password

### Appcast not updating
- Verify `SPARKLE_PRIVATE_KEY` is correct
- Check GitHub Pages is enabled on `/docs` folder
