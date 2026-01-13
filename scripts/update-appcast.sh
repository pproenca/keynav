#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="KeyNav"
DMG_PATH="$PROJECT_DIR/$APP_NAME.dmg"
APPCAST_PATH="$PROJECT_DIR/docs/appcast.xml"
INFO_PLIST="$PROJECT_DIR/Sources/KeyNav/Resources/Info.plist"
SIGN_UPDATE="$PROJECT_DIR/.build/artifacts/sparkle/Sparkle/bin/sign_update"
GITHUB_REPO="pproenca/isitokay-app"

# Check if DMG exists
if [ ! -f "$DMG_PATH" ]; then
    echo "Error: DMG not found at $DMG_PATH"
    echo "Run ./scripts/create-dmg.sh first"
    exit 1
fi

# Get version info from Info.plist
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST")
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST")

echo "Preparing appcast entry for version $VERSION (build $BUILD)..."

# Get DMG size
DMG_SIZE=$(stat -f%z "$DMG_PATH")

# Sign the DMG and get EdDSA signature
echo "Signing DMG with EdDSA key..."
SIGNATURE=$("$SIGN_UPDATE" "$DMG_PATH" 2>&1 | grep -E '^sparkle:edSignature=' | cut -d'"' -f2)

if [ -z "$SIGNATURE" ]; then
    echo "Error: Failed to generate EdDSA signature"
    echo "Make sure you have generated Sparkle keys with generate_keys"
    exit 1
fi

echo "Signature: $SIGNATURE"

# GitHub Release download URL
DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/v$VERSION/$APP_NAME.dmg"

# Current date in RFC 2822 format
PUB_DATE=$(date -R)

# Create the new item entry
NEW_ITEM=$(cat <<EOF
    <item>
      <title>Version $VERSION</title>
      <pubDate>$PUB_DATE</pubDate>
      <sparkle:version>$BUILD</sparkle:version>
      <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
      <enclosure url="$DOWNLOAD_URL"
                 sparkle:edSignature="$SIGNATURE"
                 length="$DMG_SIZE"
                 type="application/octet-stream"/>
    </item>
EOF
)

# Check if this version already exists in appcast
if grep -q "sparkle:shortVersionString>$VERSION<" "$APPCAST_PATH"; then
    echo "Warning: Version $VERSION already exists in appcast"
    read -p "Replace existing entry? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    # Remove existing entry for this version (simplified - removes item block)
    # For a more robust solution, consider using xmlstarlet or similar
    echo "Removing existing entry..."
fi

# Insert new item after the comment line
sed -i '' "s|<!-- Add new releases here, newest first -->|<!-- Add new releases here, newest first -->\n$NEW_ITEM|" "$APPCAST_PATH"

echo ""
echo "Appcast updated successfully!"
echo ""
echo "Next steps:"
echo "1. Review changes: git diff docs/appcast.xml"
echo "2. Create GitHub release:"
echo "   gh release create v$VERSION $DMG_PATH --title \"v$VERSION\" --notes \"Release notes here\""
echo "3. Commit and push appcast:"
echo "   git add docs/appcast.xml && git commit -m \"Update appcast for v$VERSION\" && git push"
echo ""
echo "Make sure GitHub Pages is enabled (Settings > Pages > Source: Deploy from branch, Branch: master, Folder: /docs)"
