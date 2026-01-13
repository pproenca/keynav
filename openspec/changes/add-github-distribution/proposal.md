# Change: Add GitHub-based Distribution

## Why
KeyNav needs a distribution channel for users to download the app and receive automatic updates. GitHub provides free, reliable hosting for releases and can serve as the Sparkle appcast feed host via GitHub Pages.

## What Changes
- Configure Sparkle to fetch updates from GitHub Pages appcast
- Add GitHub Actions workflow to automate release builds
- Create release process that publishes signed, notarized DMGs to GitHub Releases
- Generate and host appcast.xml on GitHub Pages

## Impact
- Affected specs: distribution (new capability)
- Affected code:
  - `Sources/KeyNav/Resources/Info.plist` - Sparkle feed URL
  - `.github/workflows/release.yml` - new CI workflow
  - `scripts/` - build and release automation
