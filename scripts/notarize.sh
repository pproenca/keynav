#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="KeyNav"
BUNDLE_DIR="$PROJECT_DIR/$APP_NAME.app"
ZIP_PATH="$PROJECT_DIR/$APP_NAME.zip"
TEAM_ID="X7A5P2XW9X"
KEYCHAIN_PROFILE="AC_PASSWORD"

# Check if app bundle exists
if [ ! -d "$BUNDLE_DIR" ]; then
    echo "Error: App bundle not found at $BUNDLE_DIR"
    echo "Run ./scripts/build-app.sh first"
    exit 1
fi

# Check if credentials are stored
if ! xcrun notarytool history --keychain-profile "$KEYCHAIN_PROFILE" > /dev/null 2>&1; then
    echo "Notarization credentials not found in keychain."
    echo ""
    echo "To store credentials, run:"
    echo "  xcrun notarytool store-credentials \"$KEYCHAIN_PROFILE\" \\"
    echo "      --apple-id \"your-apple-id@email.com\" \\"
    echo "      --team-id \"$TEAM_ID\" \\"
    echo "      --password \"your-app-specific-password\""
    echo ""
    echo "Get an app-specific password at: https://appleid.apple.com/account/manage"
    exit 1
fi

echo "Creating zip for notarization..."
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$BUNDLE_DIR" "$ZIP_PATH"

echo "Submitting to Apple for notarization..."
echo "(This may take a few minutes)"
xcrun notarytool submit "$ZIP_PATH" \
    --keychain-profile "$KEYCHAIN_PROFILE" \
    --wait

echo "Stapling notarization ticket to app..."
xcrun stapler staple "$BUNDLE_DIR"

echo "Verifying notarization..."
xcrun stapler validate "$BUNDLE_DIR"

# Clean up
rm -f "$ZIP_PATH"

echo ""
echo "Notarization complete!"
echo "App is ready for distribution: $BUNDLE_DIR"
echo ""
echo "To create a DMG, run: ./scripts/create-dmg.sh"
