#!/bin/bash

# Set error handling
set -e

# Configuration
PROJECT_NAME="FloppyDuck"
SCHEME_NAME="FloppyDuck"
WORKSPACE_PATH="$PROJECT_NAME.xcworkspace"
ARCHIVE_PATH="build/$PROJECT_NAME.xcarchive"
EXPORT_PATH="build/Export"
IPA_PATH="$EXPORT_PATH/$PROJECT_NAME.ipa"
EXPORT_OPTIONS="ExportOptions.plist"

# Apple ID credentials (replace with your actual credentials or use App Store Connect API Key)
APPLE_ID="your@email.com"
APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx" # Generate from appleid.apple.com

# Create build directory if it doesn't exist
mkdir -p build

echo "📦 Archiving project..."
xcodebuild clean archive \
    -workspace "$WORKSPACE_PATH" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Manual

echo "📱 Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$EXPORT_PATH" \
    -allowProvisioningUpdates

echo "🚀 Uploading to TestFlight..."
xcrun altool --upload-app \
    --file "$IPA_PATH" \
    --type ios \
    --username "$APPLE_ID" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --verbose

echo "✅ Process completed!"
echo "Please wait for Apple to process the build (usually 15-30 minutes)."
echo "You'll receive an email once the build is ready for testing." 