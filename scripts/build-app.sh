#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="KeyNav"
BUNDLE_DIR="$PROJECT_DIR/$APP_NAME.app"
BUILD_DIR="$PROJECT_DIR/.build/release"
SIGNING_IDENTITY="Developer ID Application: Pedro Moreira Proença (X7A5P2XW9X)"

echo "Building $APP_NAME..."
cd "$PROJECT_DIR"
swift build -c release

echo "Creating app bundle..."
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Frameworks"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$BUNDLE_DIR/Contents/MacOS/"

# Copy Info.plist
cp "Sources/KeyNav/Resources/Info.plist" "$BUNDLE_DIR/Contents/"

# Copy Sparkle.framework
echo "Embedding Sparkle.framework..."
cp -R "$BUILD_DIR/Sparkle.framework" "$BUNDLE_DIR/Contents/Frameworks/"

# Update rpath so executable can find Sparkle in Frameworks directory
echo "Updating library paths..."
install_name_tool -add_rpath "@executable_path/../Frameworks" "$BUNDLE_DIR/Contents/MacOS/$APP_NAME"

# Sign the frameworks first, then the app
echo "Signing app bundle with Developer ID..."
codesign --force --options runtime --timestamp \
    --sign "$SIGNING_IDENTITY" \
    "$BUNDLE_DIR/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc"
codesign --force --options runtime --timestamp \
    --sign "$SIGNING_IDENTITY" \
    "$BUNDLE_DIR/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc"
codesign --force --options runtime --timestamp \
    --sign "$SIGNING_IDENTITY" \
    "$BUNDLE_DIR/Contents/Frameworks/Sparkle.framework/Versions/B/Autoupdate"
codesign --force --options runtime --timestamp \
    --sign "$SIGNING_IDENTITY" \
    "$BUNDLE_DIR/Contents/Frameworks/Sparkle.framework/Versions/B/Updater.app"
codesign --force --options runtime --timestamp \
    --sign "$SIGNING_IDENTITY" \
    "$BUNDLE_DIR/Contents/Frameworks/Sparkle.framework"
codesign --force --options runtime --timestamp \
    --sign "$SIGNING_IDENTITY" \
    "$BUNDLE_DIR"

echo "Verifying signature..."
codesign --verify --deep --strict "$BUNDLE_DIR"
echo "Signature verified successfully."

echo ""
echo "Done! App bundle created at: $BUNDLE_DIR"
echo ""
echo "To notarize, run: ./scripts/notarize.sh"
echo "To create DMG, run: ./scripts/create-dmg.sh"
echo ""
echo "Launching KeyNav..."
open "$BUNDLE_DIR"
