## 1. Sparkle Configuration
- [x] 1.1 Generate EdDSA signing keys for Sparkle updates
- [x] 1.2 Store private key securely (not in repo) - stored in macOS Keychain
- [x] 1.3 Update Info.plist with GitHub Pages appcast URL
- [x] 1.4 Update Info.plist with public EdDSA key

## 2. GitHub Pages Setup
- [ ] 2.1 Enable GitHub Pages on repository (Settings > Pages > Source: master branch, /docs folder) - **Manual step**
- [x] 2.2 Create initial appcast.xml template
- [ ] 2.3 Verify appcast URL is accessible (after enabling GitHub Pages) - **Manual step**

## 3. Release Automation
- [x] 3.1 Create script to generate signed appcast entries
- [x] 3.2 Create GitHub Actions workflow for release builds
- [ ] 3.3 Configure GitHub Actions secrets - **Manual step, see RELEASING.md**
- [ ] 3.4 Test release workflow - **Manual step: push a version tag**

## 4. Documentation
- [x] 4.1 Document release process in RELEASING.md
- [x] 4.2 Document required secrets and setup steps
