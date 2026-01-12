#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="KeyNav"
BUNDLE_DIR="$PROJECT_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."
cd "$PROJECT_DIR"
swift build -c release

echo "Creating app bundle..."
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

# Copy executable
cp ".build/release/$APP_NAME" "$BUNDLE_DIR/Contents/MacOS/"

# Copy Info.plist
cp "Sources/KeyNav/Resources/Info.plist" "$BUNDLE_DIR/Contents/"

# Sign the app (ad-hoc if no Developer ID)
echo "Signing app bundle..."
codesign --force --deep --sign - "$BUNDLE_DIR" 2>/dev/null || true

echo ""
echo "Done! App bundle created at: $BUNDLE_DIR"
echo ""
echo "To use:"
echo "  1. Open System Settings > Privacy & Security > Accessibility"
echo "  2. Click '+' and add: $BUNDLE_DIR"
echo "  3. Run: open $BUNDLE_DIR"
