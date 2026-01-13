#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="KeyNav"
BUNDLE_DIR="$PROJECT_DIR/$APP_NAME.app"
DMG_PATH="$PROJECT_DIR/$APP_NAME.dmg"
DMG_TEMP_DIR="$PROJECT_DIR/.dmg_temp"
SIGNING_IDENTITY="Developer ID Application: Pedro Moreira Proença (X7A5P2XW9X)"
KEYCHAIN_PROFILE="AC_PASSWORD"

# Check if app bundle exists
if [ ! -d "$BUNDLE_DIR" ]; then
    echo "Error: App bundle not found at $BUNDLE_DIR"
    echo "Run ./scripts/build-app.sh first"
    exit 1
fi

# Check if app is notarized
if ! xcrun stapler validate "$BUNDLE_DIR" > /dev/null 2>&1; then
    echo "Warning: App is not notarized. Run ./scripts/notarize.sh first for full distribution."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Creating DMG..."

# Clean up
rm -rf "$DMG_TEMP_DIR"
rm -f "$DMG_PATH"

# Create temp directory with app and Applications symlink
mkdir -p "$DMG_TEMP_DIR"
cp -R "$BUNDLE_DIR" "$DMG_TEMP_DIR/"
ln -s /Applications "$DMG_TEMP_DIR/Applications"

# Create DMG
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_TEMP_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

# Clean up temp directory
rm -rf "$DMG_TEMP_DIR"

# Sign the DMG
echo "Signing DMG..."
codesign --force --sign "$SIGNING_IDENTITY" --timestamp "$DMG_PATH"

# Notarize the DMG
echo "Notarizing DMG..."
if xcrun notarytool history --keychain-profile "$KEYCHAIN_PROFILE" > /dev/null 2>&1; then
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$KEYCHAIN_PROFILE" \
        --wait
    xcrun stapler staple "$DMG_PATH"
    echo "DMG notarized successfully!"
else
    echo "Warning: Keychain profile not found. Skipping DMG notarization."
    echo "The DMG is signed but not notarized."
fi

echo ""
echo "DMG created at: $DMG_PATH"
echo ""
echo "Ready for distribution!"
