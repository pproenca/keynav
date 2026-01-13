## Context
KeyNav is a macOS accessibility app distributed outside the App Store. Users need a way to download the app and receive automatic updates. The app already has Sparkle framework embedded but not configured.

**Constraints:**
- Must use Developer ID signing (not App Store)
- Must be notarized for Gatekeeper
- Sparkle requires EdDSA-signed updates
- No budget for paid hosting

## Goals / Non-Goals
**Goals:**
- Free, reliable distribution via GitHub
- Automatic updates via Sparkle
- Reproducible release process
- Secure key management

**Non-Goals:**
- Paid CDN or hosting
- Custom download analytics (GitHub provides basic stats)
- Delta updates (full DMG downloads only for v1)

## Decisions

### Decision: GitHub Releases for DMG hosting
GitHub Releases provides:
- Free hosting with high availability
- Direct download URLs for DMGs
- Version history and release notes
- Integration with git tags

**Alternatives considered:**
- S3/CloudFront: Costs money, more complex
- Own server: Maintenance burden, reliability concerns
- Homebrew Cask: Adds dependency on external maintainers

### Decision: GitHub Pages for appcast.xml
Host the Sparkle appcast feed on GitHub Pages:
- URL: `https://pproenca.github.io/isitokay-app/appcast.xml`
- Auto-deployed from `gh-pages` branch or `docs/` folder
- Free and integrated with repository

**Alternatives considered:**
- Raw GitHub file: Unreliable, may have caching issues
- Gist: Less professional, harder to automate

### Decision: Fully automated releases via GitHub Actions
Releases are triggered by pushing a version tag (e.g., `v0.1.0`). The workflow:
1. Builds the app
2. Signs with Developer ID certificate
3. Notarizes with Apple
4. Creates signed DMG
5. Updates appcast.xml with EdDSA signature
6. Creates GitHub Release with DMG attached
7. Commits appcast changes back to repo

### Decision: Secrets stored in GitHub Actions
All signing credentials stored as GitHub repository secrets:
- Developer ID certificate (base64-encoded .p12)
- Apple ID and app-specific password for notarization
- Sparkle EdDSA private key for update signing

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Private key loss | Document backup procedure, consider hardware key |
| Manual release errors | Script automates most steps, checklist in docs |
| GitHub rate limits | Unlikely for small user base |
| GitHub Pages downtime | Rare, acceptable for v1 |

## Migration Plan
1. Generate Sparkle keys locally
2. Update Info.plist with feed URL and public key
3. Create first release manually
4. Verify update check works from installed app

## Open Questions
- ~~What is the GitHub username/repo for the appcast URL?~~ **Resolved:** `pproenca/isitokay-app`
- ~~Should we enable automatic update checks on app launch, or only manual "Check for Updates"?~~ **Resolved:** Both - Sparkle checks automatically on launch and provides manual "Check for Updates" menu item
