#!/bin/bash

# Script to run all tests for Floppy Duck before building for TestFlight
# Exit immediately if a command exits with a non-zero status
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="FloppyDuck"
WORKSPACE="FloppyDuck.xcworkspace"
SCHEME="FloppyDuck"
DERIVED_DATA_PATH="build/DerivedData"

# Print header
echo -e "${YELLOW}======================================${NC}"
echo -e "${YELLOW}   Floppy Duck Pre-Upload Testing     ${NC}"
echo -e "${YELLOW}======================================${NC}"
echo ""

# Create derived data directory if it doesn't exist
mkdir -p "$DERIVED_DATA_PATH"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check requirements
echo -e "${YELLOW}Checking requirements...${NC}"
if ! command_exists xcodebuild; then
    echo -e "${RED}Error: xcodebuild not found. Make sure Xcode is installed.${NC}"
    exit 1
fi

if [ ! -f "$WORKSPACE" ]; then
    # Try project file if workspace doesn't exist
    if [ -f "$PROJECT_NAME.xcodeproj/project.pbxproj" ]; then
        echo -e "${YELLOW}Workspace not found, using project file instead.${NC}"
        WORKSPACE="$PROJECT_NAME.xcodeproj"
    else
        echo -e "${RED}Error: Neither workspace nor project file found.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Requirements satisfied${NC}"
echo ""

# Run unit tests
echo -e "${YELLOW}Running unit tests...${NC}"
xcodebuild test \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest' \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -quiet || { echo -e "${RED}Unit tests failed${NC}"; exit 1; }

echo -e "${GREEN}✓ Unit tests passed${NC}"
echo ""

# Run UI tests if they exist
echo -e "${YELLOW}Running UI tests...${NC}"
xcodebuild test \
    -workspace "$WORKSPACE" \
    -scheme "${SCHEME}UITests" \
    -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest' \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -quiet || { 
        echo -e "${YELLOW}UI tests failed or not available. This is acceptable if UI tests are not set up.${NC}"
    }

echo ""

# Static code analysis
echo -e "${YELLOW}Running static analysis...${NC}"
if command_exists swiftlint; then
    swiftlint || echo -e "${YELLOW}SwiftLint found issues. Review them before proceeding.${NC}"
else
    echo -e "${YELLOW}SwiftLint not installed. Skipping static analysis.${NC}"
    echo "To install: brew install swiftlint"
fi

echo ""

# Check for common issues
echo -e "${YELLOW}Checking for common issues...${NC}"

# 1. Check Info.plist
if [ ! -f "$PROJECT_NAME/Info.plist" ]; then
    echo -e "${RED}Warning: Info.plist not found at expected location.${NC}"
else
    echo -e "${GREEN}✓ Info.plist found${NC}"
fi

# 2. Check for missing frameworks
echo -e "${YELLOW}Checking for required frameworks...${NC}"
REQUIRED_FRAMEWORKS=("GameKit" "SpriteKit" "UIKit")
for framework in "${REQUIRED_FRAMEWORKS[@]}"; do
    grep -r "import $framework" --include="*.swift" . > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $framework is imported${NC}"
    else
        echo -e "${YELLOW}Warning: $framework might not be imported in any Swift file.${NC}"
    fi
done

echo ""
echo -e "${GREEN}Pre-upload tests completed! If all tests passed, you can proceed with the upload.${NC}"
echo -e "${YELLOW}To build and upload to TestFlight, run:${NC}"
echo -e "./build_and_upload.sh"
echo "" 